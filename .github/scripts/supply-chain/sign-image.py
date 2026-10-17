"""Sign a verified AVOS ECR image and verify its signing identity."""

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
REPOSITORY = "Gabinsime75/African-Vibe-Online-Shop-AVOS"
REGION = "us-east-2"
REGISTRY = "396913735153.dkr.ecr.us-east-2.amazonaws.com"
IDENTITY = (
    f"https://github.com/{REPOSITORY}/"
    ".github/workflows/avos-service-ci.yml@refs/heads/main"
)
ISSUER = "https://token.actions.githubusercontent.com"


def run(*command, env=None):
    return subprocess.check_output(
        command,
        cwd=ROOT,
        env=env,
        text=True,
        timeout=180,
    ).strip()


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, value):
    path.write_text(
        json.dumps(value, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def file_sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_publication(policy, receipt, service, source_sha, image_id):
    if (
        policy.get("schema_version") != 1
        or policy.get("registry") != REGISTRY
        or policy.get("repository_prefix") != "avos/dev/"
        or policy.get("certificate_identity") != IDENTITY
        or policy.get("certificate_oidc_issuer") != ISSUER
        or policy.get("require_digest_reference") is not True
        or policy.get("require_workflow_commit") is not True
    ):
        raise ValueError("Unsupported or weakened verification policy.")

    services = policy.get("services")
    if (
        not isinstance(services, list)
        or not all(isinstance(item, str) for item in services)
        or len(services) != len(set(services))
        or service not in services
        or re.fullmatch(r"[a-z][a-z0-9]*", service) is None
    ):
        raise ValueError("Service is not allowed by the verification policy.")

    if re.fullmatch(r"[0-9a-f]{40}", source_sha) is None:
        raise ValueError("Invalid source commit.")

    if re.fullmatch(r"sha256:[0-9a-f]{64}", image_id) is None:
        raise ValueError("Invalid local configuration digest.")

    digest = receipt.get("image_digest")
    if (
        not isinstance(digest, str)
        or re.fullmatch(r"sha256:[0-9a-f]{64}", digest) is None
    ):
        raise ValueError("Invalid ECR manifest digest.")

    image_repository = f"{REGISTRY}/avos/dev/{service}"
    reference = f"{image_repository}@{digest}"

    if (
        receipt.get("service") != service
        or receipt.get("source_sha") != source_sha
        or receipt.get("local_config_digest") != image_id
        or receipt.get("image_uri") != f"{image_repository}:{source_sha}"
        or receipt.get("digest_reference") != reference
        or receipt.get("status") not in {"pushed", "already-present"}
    ):
        raise ValueError("Publication receipt does not match this build.")

    return reference


def verification_command(policy, reference, source_sha):
    return [
        "cosign",
        "verify",
        "--certificate-identity",
        policy["certificate_identity"],
        "--certificate-oidc-issuer",
        policy["certificate_oidc_issuer"],
        "--certificate-github-workflow-sha",
        source_sha,
        "--output",
        "json",
        reference,
    ]


def main():
    if (
        os.environ.get("GITHUB_REPOSITORY") != REPOSITORY
        or os.environ.get("GITHUB_REF") != "refs/heads/main"
        or os.environ.get("GITHUB_EVENT_NAME")
        not in {"push", "workflow_dispatch"}
    ):
        raise ValueError("Signing requires an authorized main-branch run.")

    service = os.environ["SERVICE_NAME"]
    source_sha = os.environ["SOURCE_SHA"]
    image_id = os.environ["IMAGE_ID"]
    runner_temp = Path(os.environ["RUNNER_TEMP"])

    if run("git", "rev-parse", "HEAD") != source_sha:
        raise ValueError("Checked-out commit does not match the build.")

    policy = read_json(ROOT / ".github/policies/image-verification.json")
    publication_path = (
        runner_temp / "avos-publication" / service / "publication.json"
    )
    receipt = read_json(publication_path)

    reference = validate_publication(
        policy, receipt, service, source_sha, image_id
    )

    evidence_path = (
        runner_temp
        / "avos-supply-chain"
        / service
        / "evidence-manifest.json"
    )
    if receipt.get("supply_chain_manifest_sha256") != file_sha256(evidence_path):
        raise ValueError("Publication evidence checksum does not match.")

    response = json.loads(
        run(
            "aws", "ecr", "batch-get-image",
            "--region", REGION,
            "--repository-name", f"avos/dev/{service}",
            "--image-ids", f"imageTag={source_sha}",
            "--accepted-media-types",
            "application/vnd.docker.distribution.manifest.v2+json",
            "application/vnd.oci.image.manifest.v1+json",
            "--output", "json",
            "--no-cli-pager",
        )
    )
    images = response.get("images", [])
    if response.get("failures") or len(images) != 1:
        raise ValueError("ECR did not return exactly one published image.")

    raw_manifest = images[0]["imageManifest"]
    actual_digest = (
        "sha256:" + hashlib.sha256(raw_manifest.encode("utf-8")).hexdigest()
    )
    manifest = json.loads(raw_manifest)

    if (
        actual_digest != receipt["image_digest"]
        or images[0]["imageId"]["imageDigest"] != actual_digest
        or manifest.get("schemaVersion") != 2
        or manifest.get("config", {}).get("digest") != image_id
    ):
        raise ValueError("ECR image no longer matches the publication receipt.")

    output = runner_temp / "avos-signing" / service
    output.mkdir(parents=True, exist_ok=True)
    bundle = output / "signature.sigstore.json"

    with tempfile.TemporaryDirectory(
        prefix="avos-signing-login-", dir=runner_temp
    ) as directory:
        environment = dict(os.environ, DOCKER_CONFIG=directory)

        password = run(
            "aws", "ecr", "get-login-password", "--region", REGION
        )
        try:
            subprocess.run(
                [
                    "docker", "login",
                    "--username", "AWS",
                    "--password-stdin", REGISTRY,
                ],
                input=password + "\n",
                text=True,
                env=environment,
                check=True,
                timeout=60,
            )

            subprocess.run(
                ["cosign", "sign", "--yes", "--bundle", str(bundle), reference],
                cwd=ROOT,
                env=environment,
                check=True,
                timeout=180,
            )

            verification = json.loads(
                run(
                    *verification_command(policy, reference, source_sha),
                    env=environment,
                )
            )
            if not isinstance(verification, list) or not verification:
                raise ValueError("Cosign returned no verified signatures.")

            if not isinstance(read_json(bundle), dict):
                raise ValueError("Cosign signature bundle is invalid.")

            write_json(output / "verification.json", verification)

        finally:
            subprocess.run(
                ["docker", "logout", REGISTRY],
                env=environment,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
                timeout=30,
            )

    write_json(
        output / "signing.json",
        {
            "schema_version": 1,
            "service": service,
            "source_sha": source_sha,
            "digest_reference": reference,
            "certificate_identity": policy["certificate_identity"],
            "certificate_oidc_issuer": policy["certificate_oidc_issuer"],
            "workflow_commit_required": source_sha,
            "verified": True,
            "cosign_version": run("cosign", "version"),
            "workflow_run_id": os.environ["GITHUB_RUN_ID"],
            "workflow_run_attempt": os.environ["GITHUB_RUN_ATTEMPT"],
            "publication_sha256": file_sha256(publication_path),
            "policy_sha256": file_sha256(
                ROOT / ".github/policies/image-verification.json"
            ),
            "files_sha256": {
                name: file_sha256(output / name)
                for name in ["signature.sigstore.json", "verification.json"]
            },
        },
    )

    print(f"PASS: signed and verified {reference}")


if __name__ == "__main__":
    main()
