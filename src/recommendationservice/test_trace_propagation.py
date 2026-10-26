"""Real two-hop gRPC propagation with collector export disabled."""

import unittest
from concurrent import futures
from unittest.mock import patch

import grpc
from opentelemetry import baggage, trace
from opentelemetry.instrumentation.grpc import GrpcInstrumentorClient, GrpcInstrumentorServer

import demo_pb2
import demo_pb2_grpc
from recommendation_server import RecommendationService, configure_tracing


class TracePropagationTest(unittest.TestCase):
    def test_recommendation_forwards_trace_to_catalog_without_export(self):
        observed = []

        class Catalog(demo_pb2_grpc.ProductCatalogServiceServicer):
            def ListProducts(self, request, context):
                observed.append((
                    trace.get_current_span().get_span_context().trace_id,
                    baggage.get_baggage("avos.test"),
                    dict(context.invocation_metadata()).get("traceparent"),
                ))
                return demo_pb2.ListProductsResponse(
                    products=[demo_pb2.Product(id="test-product")]
                )

        with patch.dict("os.environ", {"ENABLE_TRACING": "0"}):
            self.assertIsNone(configure_tracing())
        servers, channels = [], []
        try:
            catalog = grpc.server(futures.ThreadPoolExecutor(max_workers=2))
            demo_pb2_grpc.add_ProductCatalogServiceServicer_to_server(Catalog(), catalog)
            port = catalog.add_insecure_port("127.0.0.1:0")
            catalog.start()
            servers.append(catalog)
            catalog_channel = grpc.insecure_channel(f"127.0.0.1:{port}")
            channels.append(catalog_channel)
            recommendation = grpc.server(futures.ThreadPoolExecutor(max_workers=2))
            demo_pb2_grpc.add_RecommendationServiceServicer_to_server(
                RecommendationService(demo_pb2_grpc.ProductCatalogServiceStub(catalog_channel)),
                recommendation,
            )
            port = recommendation.add_insecure_port("127.0.0.1:0")
            recommendation.start()
            servers.append(recommendation)
            channel = grpc.insecure_channel(f"127.0.0.1:{port}")
            channels.append(channel)
            client = demo_pb2_grpc.RecommendationServiceStub(channel)
            trace_id = "1234567890abcdef1234567890abcdef"
            client.ListRecommendations(
                demo_pb2.ListRecommendationsRequest(user_id="test"), timeout=3,
                metadata=(("traceparent", f"00-{trace_id}-1234567890abcdef-01"),
                          ("baggage", "avos.test=propagated")),
            )
            client.ListRecommendations(demo_pb2.ListRecommendationsRequest(user_id="test"), timeout=3)
            self.assertEqual(observed[0][0], int(trace_id, 16))
            self.assertEqual(observed[0][1], "propagated")
            self.assertIn(trace_id, observed[0][2])
            self.assertNotEqual(observed[1][0], int(trace_id, 16))
            self.assertIsNone(observed[1][1])
        finally:
            for channel in channels:
                channel.close()
            for server in reversed(servers):
                server.stop(0).wait()
            GrpcInstrumentorClient().uninstrument()
            GrpcInstrumentorServer().uninstrument()
