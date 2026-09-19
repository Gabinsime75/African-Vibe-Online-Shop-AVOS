import unittest
from io import BytesIO
from unittest.mock import Mock

import grpc

import shoppingassistant_pb2
from shoppingassistantservice import (
    AssistantEngine,
    RecommendationResult,
    Settings,
    ShoppingAssistantServicer,
)


class AbortError(Exception):
    pass


class FakeContext:
    def __init__(self):
        self.code = None
        self.details = None

    def abort(self, code, details):
        self.code = code
        self.details = details
        raise AbortError(details)


class ShoppingAssistantServicerTest(unittest.TestCase):
    def setUp(self):
        self.engine = Mock()
        self.service = ShoppingAssistantServicer(self.engine, max_image_bytes=8)

    def test_returns_content_and_explicit_product_ids(self):
        self.engine.recommend.return_value = RecommendationResult(
            content="These woven accents complement your space.",
            product_ids=["AVOS-001", "AVOS-002"],
        )
        request = shoppingassistant_pb2.ShoppingAssistantRequest(
            user_id="session-1", prompt="Recommend woven decor"
        )

        response = self.service.GetRecommendations(request, FakeContext())

        self.assertEqual(response.content, "These woven accents complement your space.")
        self.assertEqual(list(response.product_ids), ["AVOS-001", "AVOS-002"])
        self.engine.recommend.assert_called_once_with("Recommend woven decor", b"", "")

    def test_rejects_empty_request(self):
        context = FakeContext()
        with self.assertRaises(AbortError):
            self.service.GetRecommendations(
                shoppingassistant_pb2.ShoppingAssistantRequest(), context
            )
        self.assertEqual(context.code, grpc.StatusCode.INVALID_ARGUMENT)

    def test_rejects_oversized_image(self):
        context = FakeContext()
        with self.assertRaises(AbortError):
            self.service.GetRecommendations(
                shoppingassistant_pb2.ShoppingAssistantRequest(
                    image=b"123456789", image_media_type="image/png"
                ),
                context,
            )
        self.assertEqual(context.code, grpc.StatusCode.RESOURCE_EXHAUSTED)

    def test_dependency_failure_is_unavailable(self):
        self.engine.recommend.side_effect = RuntimeError("dependency failed")
        context = FakeContext()
        with self.assertRaises(AbortError):
            self.service.GetRecommendations(
                shoppingassistant_pb2.ShoppingAssistantRequest(prompt="help"), context
            )
        self.assertEqual(context.code, grpc.StatusCode.UNAVAILABLE)


class AssistantEngineTest(unittest.TestCase):
    def test_runs_multimodal_retrieval_augmented_flow(self):
        settings = Settings(
            aws_region="us-east-2",
            bedrock_model_id="test-chat-model",
            embedding_model_id="test-embedding-model",
            opensearch_endpoint="search.example.com",
            opensearch_index="avos-products",
            opensearch_service="es",
            port=8080,
            top_k=3,
            max_image_bytes=1024,
            request_timeout_seconds=20,
        )
        bedrock = Mock()
        bedrock.converse.side_effect = [
            {"output": {"message": {"content": [{"text": "Warm woven room"}]}}},
            {"output": {"message": {"content": [{"text": "Try this basket."}]}}},
        ]
        bedrock.invoke_model.return_value = {
            "body": BytesIO(b'{"embedding": [0.1, 0.2]}')
        }
        search = Mock()
        search.search.return_value = {
            "hits": {
                "hits": [
                    {
                        "_source": {
                            "id": "AVOS-001",
                            "name": "Woven basket",
                            "description": "Handwoven storage basket",
                            "categories": ["decor"],
                        }
                    }
                ]
            }
        }
        engine = AssistantEngine(settings, bedrock_client=bedrock, search_client=search)

        result = engine.recommend("Find storage", b"image", "image/jpeg")

        self.assertEqual(result.content, "Try this basket.")
        self.assertEqual(result.product_ids, ["AVOS-001"])
        self.assertEqual(bedrock.converse.call_count, 2)
        bedrock.invoke_model.assert_called_once()
        search.search.assert_called_once()


if __name__ == "__main__":
    unittest.main()
