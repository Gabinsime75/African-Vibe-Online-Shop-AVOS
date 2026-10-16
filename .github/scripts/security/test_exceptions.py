from datetime import date
from pathlib import Path
import runpy
import unittest

apply_exceptions = runpy.run_path(
    str(Path(__file__).with_name("check-reports.py"))
)["apply_exceptions"]


class ExceptionPolicyTests(unittest.TestCase):
    def entry(self):
        return {
            "id": "AWS-0040",
            "target": "container-platform/eks-cluster.tf",
            "expires": "2026-11-15",
            "owner": "PlatformEngineering",
            "reason": "Temporary development access",
            "controls": "Restricted administrator CIDRs",
            "review": "Review private connectivity",
        }

    def test_only_exact_configuration_finding_is_accepted(self):
        findings = [
            ("misconfiguration", "AWS-0040", "container-platform/eks-cluster.tf"),
            ("misconfiguration", "AWS-0040", "other/eks-cluster.tf"),
            ("misconfiguration", "AWS-0041", "container-platform/eks-cluster.tf"),
            ("vulnerability", "AWS-0040", "container-platform/eks-cluster.tf"),
            ("secret", "AWS-0040", "container-platform/eks-cluster.tf"),
        ]
        remaining, accepted = apply_exceptions(
            findings, [self.entry()], date(2026, 10, 16)
        )
        self.assertEqual(remaining, findings[1:])
        self.assertEqual(len(accepted), 1)

    def test_expired_exception_is_rejected(self):
        with self.assertRaises(ValueError):
            apply_exceptions([], [self.entry()], date(2026, 11, 15))

    def test_wildcard_exception_is_rejected(self):
        entry = self.entry()
        entry["target"] = "container-platform/*"
        with self.assertRaises(ValueError):
            apply_exceptions([], [entry], date(2026, 10, 16))

    def test_duplicate_exception_is_rejected(self):
        with self.assertRaises(ValueError):
            apply_exceptions(
                [], [self.entry(), self.entry()], date(2026, 10, 16)
            )


if __name__ == "__main__":
    unittest.main()
