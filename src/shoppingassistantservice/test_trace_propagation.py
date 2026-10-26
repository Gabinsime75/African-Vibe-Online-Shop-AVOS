"""Verify W3C metadata on a real assistant RPC without AWS or a collector."""

import time
import unittest
from unittest.mock import Mock, patch

import grpc
from opentelemetry import baggage, context, trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.sampling import ALWAYS_ON
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.sdk.trace.export.in_memory_span_exporter import InMemorySpanExporter

import shoppingassistant_pb2
import shoppingassistant_pb2_grpc
from shoppingassistantservice import RecommendationResult, Settings, create_server


class TracePropagationTest(unittest.TestCase):
    def test_inbound_parent_baggage_and_request_isolation(self):
        exporter = InMemorySpanExporter()
        provider = TracerProvider(sampler=ALWAYS_ON)
        provider.add_span_processor(SimpleSpanProcessor(exporter))
        observed = []

        def recommend(*_args):
            observed.append((
                trace.get_current_span().get_span_context().trace_id,
                baggage.get_baggage("avos.test"),
            ))
            return RecommendationResult("test recommendation", ["test-product"])

        engine = Mock()
        engine.recommend.side_effect = recommend
        settings = Settings("us-east-2", "fake", "fake", "https://invalid.example",
                            "test", "es", 0, 1, 1024, 1)
        server = create_server(settings, engine=engine)
        port = server.add_insecure_port("127.0.0.1:0")
        server.start()
        channel = grpc.insecure_channel(f"127.0.0.1:{port}")
        client = shoppingassistant_pb2_grpc.ShoppingAssistantServiceStub(channel)
        trace_id = "1234567890abcdef1234567890abcdef"
        metadata = (("traceparent", f"00-{trace_id}-1234567890abcdef-01"),
                    ("baggage", "avos.test=propagated"))
        try:
            with patch("shoppingassistantservice.trace.get_tracer",
                       return_value=provider.get_tracer("test")):
                client.GetRecommendations(
                    shoppingassistant_pb2.ShoppingAssistantRequest(prompt="test"),
                    metadata=metadata, timeout=3,
                )
                client.GetRecommendations(
                    shoppingassistant_pb2.ShoppingAssistantRequest(prompt="test"),
                    timeout=3,
                )
                client.GetRecommendations(
                    shoppingassistant_pb2.ShoppingAssistantRequest(prompt="test"),
                    metadata=(("traceparent", "malformed"),), timeout=3,
                )
            self.assertEqual(observed[0], (int(trace_id, 16), "propagated"))
            self.assertNotEqual(observed[1][0], int(trace_id, 16))
            self.assertIsNone(observed[1][1])
            self.assertNotEqual(observed[2][0], int(trace_id, 16))
            deadline = time.monotonic() + 3
            while time.monotonic() < deadline:
                spans = [s for s in exporter.get_finished_spans()
                         if s.kind == trace.SpanKind.SERVER]
                if len(spans) == 3:
                    break
                time.sleep(0.01)
            self.assertEqual(len(spans), 3)
            self.assertEqual(spans[0].parent.span_id, int("1234567890abcdef", 16))
            self.assertIsNone(spans[1].parent)
            self.assertIsNone(spans[2].parent)
            self.assertFalse(trace.get_current_span().get_span_context().is_valid)
        finally:
            channel.close()
            server.stop(0).wait()
            provider.shutdown()
