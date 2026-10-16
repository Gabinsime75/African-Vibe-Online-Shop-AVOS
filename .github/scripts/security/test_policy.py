import copy
from pathlib import Path
import runpy
import unittest

evaluate = runpy.run_path(
    str(Path(__file__).with_name("check-reports.py"))
)["evaluate"]


def report(result):
    return {"SchemaVersion": 2, "Results": [result]}


class SecurityPolicyTests(unittest.TestCase):
    def test_vulnerability_threshold(self):
        for severity in ["LOW", "MEDIUM", "HIGH", "CRITICAL"]:
            with self.subTest(severity=severity):
                blockers, _ = evaluate(report({
                    "Vulnerabilities": [{
                        "VulnerabilityID": "CVE-TEST",
                        "Severity": severity,
                    }]
                }))
                self.assertEqual(bool(blockers), severity == "CRITICAL")

    def test_secret_and_configuration_thresholds(self):
        for severity in ["LOW", "MEDIUM", "HIGH", "CRITICAL"]:
            for category in ["Secrets", "Misconfigurations"]:
                with self.subTest(severity=severity, category=category):
                    blockers, _ = evaluate(report({
                        category: [{"Severity": severity, "Status": "FAIL"}]
                    }))
                    self.assertEqual(
                        bool(blockers), severity in {"HIGH", "CRITICAL"}
                    )

    def test_successful_configuration_is_not_blocked(self):
        blockers, _ = evaluate(report({
            "Misconfigurations": [{
                "Severity": "CRITICAL",
                "Status": "PASS",
            }]
        }))
        self.assertEqual(blockers, [])

    def test_sensitive_report_content_is_removed(self):
        data = report({
            "Secrets": [{
                "RuleID": "test",
                "Severity": "HIGH",
                "Match": "synthetic-sensitive-value",
                "Code": {"Lines": ["synthetic-sensitive-value"]},
            }],
            "Misconfigurations": [{
                "Severity": "LOW",
                "CauseMetadata": {"Code": "synthetic-sensitive-value"},
            }],
        })
        data["Metadata"] = {
            "ImageConfig": {"Env": ["TOKEN=synthetic-sensitive-value"]}
        }
        evaluate(data)
        self.assertNotIn("synthetic-sensitive-value", str(data))
        self.assertEqual(data["Results"][0]["Secrets"][0]["RuleID"], "test")

    def test_invalid_reports_are_rejected(self):
        for invalid in [{}, {"SchemaVersion": 2}, {"SchemaVersion": 1}]:
            with self.subTest(report=invalid):
                with self.assertRaises(ValueError):
                    evaluate(copy.deepcopy(invalid))


if __name__ == "__main__":
    unittest.main()
