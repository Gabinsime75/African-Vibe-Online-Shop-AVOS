"""Exercise the actual process SIGTERM path without external dependencies."""

import os
from pathlib import Path
import socket
import subprocess
import sys
import unittest

import grpc
from grpc_health.v1 import health_pb2, health_pb2_grpc


class ProcessShutdownTest(unittest.TestCase):
    def test_sigterm_exits_cleanly_after_serving_health(self):
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", 0))
            port = listener.getsockname()[1]
        environment = dict(
            os.environ,
            PORT=str(port),
            PRODUCT_CATALOG_SERVICE_ADDR="127.0.0.1:1",
            ENABLE_TRACING="0",
            SHUTDOWN_GRACE_SECONDS="1",
        )
        with subprocess.Popen(
            [sys.executable, str(Path(__file__).with_name("recommendation_server.py"))],
            env=environment,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        ) as process:
            try:
                with grpc.insecure_channel(f"127.0.0.1:{port}") as channel:
                    grpc.channel_ready_future(channel).result(timeout=8)
                    status = health_pb2_grpc.HealthStub(channel).Check(
                        health_pb2.HealthCheckRequest(), timeout=2
                    )
                    self.assertEqual(status.status, health_pb2.HealthCheckResponse.SERVING)
                    process.terminate()
                    output, _ = process.communicate(timeout=8)
                self.assertEqual(process.returncode, 0, output)
            finally:
                if process.poll() is None:
                    process.kill()
                    process.communicate()


if __name__ == "__main__":
    unittest.main()
