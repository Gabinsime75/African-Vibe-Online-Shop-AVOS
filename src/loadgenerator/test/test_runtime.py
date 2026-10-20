from pathlib import Path
import runpy
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from locust.env import Environment


MODULE = runpy.run_path(
    str(Path(__file__).resolve().parents[1] / "locustfile.py")
)


class RuntimeTests(unittest.TestCase):
    def test_startup_uses_real_fast_http_client(self):
        with patch.object(
            MODULE["AVOSShopper"], "host", "http://127.0.0.1:8080"
        ):
            shopper = MODULE["AVOSShopper"](Environment())
        with patch.object(shopper.client, "get") as request:
            shopper.on_start()
        request.assert_called_once_with("/", name="GET /")
        self.assertEqual(
            shopper.default_headers["User-Agent"],
            "AVOS-LoadGenerator/1.0",
        )

    def test_invalid_runs_return_failure(self):
        for requests, failures, exceptions in [
            (0, 0, {}),
            (10, 1, {}),
            (10, 0, {"startup": {"count": 1}}),
        ]:
            with self.subTest(
                requests=requests, failures=failures, exceptions=exceptions
            ):
                environment = SimpleNamespace(
                    stats=SimpleNamespace(total=SimpleNamespace(
                        num_requests=requests,
                        num_failures=failures,
                    )),
                    runner=SimpleNamespace(exceptions=exceptions),
                    process_exit_code=None,
                )
                MODULE["validate_run"](environment)
                self.assertEqual(environment.process_exit_code, 1)

    def test_successful_run_preserves_exit_status(self):
        environment = SimpleNamespace(
            stats=SimpleNamespace(total=SimpleNamespace(
                num_requests=10,
                num_failures=0,
            )),
            runner=SimpleNamespace(exceptions={}),
            process_exit_code=None,
        )
        MODULE["validate_run"](environment)
        self.assertIsNone(environment.process_exit_code)
