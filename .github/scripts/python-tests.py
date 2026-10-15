"""Run AVOS Python unit tests and reject empty or entirely skipped suites."""

import os
from pathlib import Path
import sys
import unittest

TEST_DIRECTORIES = {
    "emailservice": "test",
    "recommendationservice": ".",
    "shoppingassistantservice": ".",
    "loadgenerator": "test",
}

if len(sys.argv) != 2 or sys.argv[1] not in TEST_DIRECTORIES:
    raise SystemExit("Provide a supported AVOS Python service name.")

service = sys.argv[1]
repository = Path(__file__).resolve().parents[2]
service_directory = repository / "src" / service

os.chdir(service_directory)
sys.path.insert(0, str(service_directory))

suite = unittest.TestLoader().discover(
    start_dir=TEST_DIRECTORIES[service],
    pattern="test_*.py",
)

count = suite.countTestCases()
print(f"Discovered {count} tests for {service}", flush=True)

if count == 0:
    raise SystemExit("No unit tests discovered.")

result = unittest.TextTestRunner(verbosity=2).run(suite)

if result.testsRun == len(result.skipped):
    raise SystemExit("All discovered tests were skipped.")

raise SystemExit(0 if result.wasSuccessful() else 1)
