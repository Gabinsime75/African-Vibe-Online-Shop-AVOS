import copy
import json
from pathlib import Path
import runpy
import unittest

DIRECTORY = Path(__file__).resolve().parent
ROOT = DIRECTORY.parents[2]
SIGNING = runpy.run_path(str(DIRECTORY / "sign-image.py"))
validate = SIGNING["validate_publication"]
verification_command = SIGNING["verification_command"]


class SigningTests(unittest.TestCase):
    def setUp(self):
        self.policy = json.loads(
            (ROOT / ".github/policies/image-verification.json").read_text(
                encoding="utf-8"
            )
        )
        self.source_sha = "a" * 40
        self.image_id = "sha256:" + "b" * 64
        self.digest = "sha256:" + "c" * 64
        repository = f'{self.policy["registry"]}/avos/dev/frontend'
        self.reference = f"{repository}@{self.digest}"
        self.receipt = {
            "service": "frontend",
            "source_sha": self.source_sha,
            "local_config_digest": self.image_id,
            "image_uri": f"{repository}:{self.source_sha}",
            "image_digest": self.digest,
            "digest_reference": self.reference,
            "status": "pushed",
        }

    def check(self, policy=None, receipt=None, source_sha=None):
        return validate(
            self.policy if policy is None else policy,
            self.receipt if receipt is None else receipt,
            "frontend",
            self.source_sha if source_sha is None else source_sha,
            self.image_id,
        )

    def test_matching_publication_is_accepted(self):
        self.assertEqual(self.check(), self.reference)
        self.receipt["status"] = "already-present"
        self.assertEqual(self.check(), self.reference)

    def test_weakened_policy_is_rejected(self):
        changes = {
            "schema_version": 2,
            "registry": "other.example.com",
            "repository_prefix": "",
            "certificate_identity": ".*",
            "certificate_oidc_issuer": "https://other.example.com",
            "require_digest_reference": False,
            "require_workflow_commit": False,
        }
        for field, value in changes.items():
            with self.subTest(field=field):
                policy = copy.deepcopy(self.policy)
                policy[field] = value
                with self.assertRaises(ValueError):
                    self.check(policy=policy)

    def test_mismatched_or_missing_receipt_fields_are_rejected(self):
        changes = {
            "service": "paymentservice",
            "source_sha": "d" * 40,
            "local_config_digest": "sha256:" + "d" * 64,
            "image_uri": self.receipt["image_uri"].replace("frontend", "other"),
            "image_digest": "sha256:invalid",
            "digest_reference": self.receipt["image_uri"],
            "status": "failed",
        }
        for field, value in changes.items():
            with self.subTest(field=field, case="mismatch"):
                receipt = dict(self.receipt, **{field: value})
                with self.assertRaises(ValueError):
                    self.check(receipt=receipt)
            with self.subTest(field=field, case="missing"):
                receipt = dict(self.receipt)
                del receipt[field]
                with self.assertRaises(ValueError):
                    self.check(receipt=receipt)

    def test_invalid_service_allowlists_are_rejected(self):
        for services in [
            [],
            ["*"],
            ["frontend", "frontend"],
            ["frontend", None],
            "frontend",
        ]:
            with self.subTest(services=services):
                policy = dict(self.policy, services=services)
                with self.assertRaises(ValueError):
                    self.check(policy=policy)

    def test_invalid_commit_is_rejected(self):
        for source_sha in ["main", "a" * 39, "A" * 40, ""]:
            with self.subTest(source_sha=source_sha):
                with self.assertRaises(ValueError):
                    self.check(source_sha=source_sha)

    def test_verification_requires_exact_identity_issuer_and_commit(self):
        command = verification_command(
            self.policy, self.reference, self.source_sha
        )
        for flag, value in [
            ("--certificate-identity", self.policy["certificate_identity"]),
            ("--certificate-oidc-issuer", self.policy["certificate_oidc_issuer"]),
            ("--certificate-github-workflow-sha", self.source_sha),
        ]:
            self.assertEqual(command[command.index(flag) + 1], value)

        self.assertEqual(command[-1], self.reference)
        self.assertFalse(any("insecure" in argument for argument in command))
        self.assertNotIn("--certificate-identity-regexp", command)


if __name__ == "__main__":
    unittest.main()
