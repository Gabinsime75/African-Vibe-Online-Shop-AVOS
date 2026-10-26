"""Inbound context remains available while collector export is disabled."""

import unittest
from concurrent import futures
from unittest.mock import patch

import grpc
from opentelemetry import baggage, trace
from opentelemetry.instrumentation.grpc import GrpcInstrumentorServer

from email_server import configure_telemetry


class TracePropagationTest(unittest.TestCase):
    def test_inbound_trace_and_baggage_without_export(self):
        observed = []

        def check(request, context):
            observed.append((trace.get_current_span().get_span_context().trace_id,
                             baggage.get_baggage("avos.test")))
            return b"ok"

        with patch.dict("os.environ", {"ENABLE_OTEL": "false"}):
            self.assertIsNone(configure_telemetry())
        server = grpc.server(futures.ThreadPoolExecutor(max_workers=2))
        server.add_generic_rpc_handlers((grpc.method_handlers_generic_handler(
            "avos.test.Trace", {"Check": grpc.unary_unary_rpc_method_handler(check)}
        ),))
        port = server.add_insecure_port("127.0.0.1:0")
        server.start()
        channel = grpc.insecure_channel(f"127.0.0.1:{port}")
        call = channel.unary_unary("/avos.test.Trace/Check")
        trace_id = "1234567890abcdef1234567890abcdef"
        try:
            call(b"", timeout=3, metadata=(
                ("traceparent", f"00-{trace_id}-1234567890abcdef-01"),
                ("baggage", "avos.test=propagated"),
            ))
            call(b"", timeout=3)
            self.assertEqual(observed[0], (int(trace_id, 16), "propagated"))
            self.assertNotEqual(observed[1][0], int(trace_id, 16))
            self.assertIsNone(observed[1][1])
        finally:
            channel.close()
            server.stop(0).wait()
            GrpcInstrumentorServer().uninstrument()
