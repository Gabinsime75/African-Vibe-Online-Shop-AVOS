"""Enforce AVOS security thresholds and sanitize Trivy reports."""

import argparse
import json
from pathlib import Path
import sys


def evaluate(report):
    if not isinstance(report, dict) or report.get("SchemaVersion") != 2:
        raise ValueError("Unsupported or invalid Trivy report")

    results = report.get("Results")
    if not isinstance(results, list):
        raise ValueError("Trivy report has no valid Results list")

    blockers = []
    counts = {"vulnerabilities": 0, "secrets": 0, "misconfigurations": 0}

    for result in results:
        target = result.get("Target", "unknown")

        for finding in result.get("Vulnerabilities") or []:
            counts["vulnerabilities"] += 1
            if finding.get("Severity") == "CRITICAL":
                blockers.append((
                    "vulnerability",
                    finding.get("VulnerabilityID", "unknown"),
                    target,
                ))

        secrets = result.get("Secrets") or []
        for finding in secrets:
            counts["secrets"] += 1
            if finding.get("Severity") in {"HIGH", "CRITICAL"}:
                blockers.append((
                    "secret",
                    finding.get("RuleID", "unknown"),
                    target,
                ))

        if "Secrets" in result:
            allowed = {
                "RuleID", "Category", "Severity",
                "Title", "StartLine", "EndLine",
            }
            result["Secrets"] = [
                {key: value for key, value in finding.items() if key in allowed}
                for finding in secrets
            ]

        for finding in result.get("Misconfigurations") or []:
            if finding.get("Status", "FAIL") == "FAIL":
                counts["misconfigurations"] += 1
                if finding.get("Severity") in {"HIGH", "CRITICAL"}:
                    blockers.append((
                        "misconfiguration",
                        finding.get("ID", "unknown"),
                        target,
                    ))

            finding.pop("CauseMetadata", None)
            finding.pop("Code", None)

    metadata = report.get("Metadata")
    if isinstance(metadata, dict):
        metadata.pop("ImageConfig", None)

    return blockers, counts


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("reports", nargs="+")
    args = parser.parse_args()

    output = Path(args.output_dir)
    output.mkdir(parents=True, exist_ok=True)

    names = [Path(name).name for name in args.reports]
    if len(names) != len(set(names)):
        raise ValueError("Report filenames must be unique")

    all_blockers = []

    for name in args.reports:
        path = Path(name)
        report = json.loads(path.read_text(encoding="utf-8"))
        blockers, counts = evaluate(report)

        (output / path.name).write_text(
            json.dumps(report, indent=2) + "\n",
            encoding="utf-8",
        )

        print(
            f"{path.name}: "
            f"{counts['vulnerabilities']} vulnerabilities, "
            f"{counts['secrets']} secrets, "
            f"{counts['misconfigurations']} failed configuration checks"
        )

        for category, identifier, target in blockers:
            print(f"BLOCK: {category} {identifier} in {target}")

        all_blockers.extend(blockers)

    if all_blockers:
        print(f"FAIL: {len(all_blockers)} findings exceed AVOS thresholds.")
        return 1

    print("PASS: security findings are within AVOS thresholds.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
