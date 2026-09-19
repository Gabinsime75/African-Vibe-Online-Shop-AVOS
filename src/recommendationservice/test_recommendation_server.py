#!/usr/bin/env python3

import unittest

import demo_pb2
from recommendation_server import RecommendationService


class CatalogStub:
    def __init__(self, product_ids):
        self._product_ids = product_ids
        self.timeout = None

    def ListProducts(self, request, timeout=None):
        del request
        self.timeout = timeout
        return demo_pb2.ListProductsResponse(
            products=[demo_pb2.Product(id=product_id) for product_id in self._product_ids]
        )


class PredictableRandomizer:
    def sample(self, population, count):
        return population[:count]


class RecommendationServiceTest(unittest.TestCase):
    def test_excludes_products_already_in_request(self):
        catalog = CatalogStub(["product-1", "product-2", "product-3"])
        service = RecommendationService(
            catalog,
            max_recommendations=5,
            catalog_timeout_seconds=2.5,
            randomizer=PredictableRandomizer(),
        )

        response = service.ListRecommendations(
            demo_pb2.ListRecommendationsRequest(
                user_id="test-user", product_ids=["product-2"]
            ),
            context=None,
        )

        self.assertEqual(["product-1", "product-3"], list(response.product_ids))
        self.assertEqual(2.5, catalog.timeout)

    def test_limits_number_of_recommendations(self):
        catalog = CatalogStub([f"product-{index}" for index in range(10)])
        service = RecommendationService(
            catalog,
            max_recommendations=3,
            randomizer=PredictableRandomizer(),
        )

        response = service.ListRecommendations(
            demo_pb2.ListRecommendationsRequest(user_id="test-user"),
            context=None,
        )

        self.assertEqual(3, len(response.product_ids))


if __name__ == "__main__":
    unittest.main()
