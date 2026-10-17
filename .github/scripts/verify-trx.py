"""Reject missing, failed, or empty .NET test results."""

from pathlib import Path
import sys
import xml.etree.ElementTree as ET

report = Path(sys.argv[1])
if not report.is_file():
    raise SystemExit(f"Missing test report: {report}")

results = [
    element
    for element in ET.parse(report).getroot().iter()
    if element.tag.rsplit("}", 1)[-1] == "UnitTestResult"
]

passed = sum(item.get("outcome") == "Passed" for item in results)
failed = sum(item.get("outcome") == "Failed" for item in results)

print(f".NET test results: {passed} passed, {failed} failed")

if passed == 0 or failed:
    raise SystemExit("At least one passing test and no failed tests are required.")
