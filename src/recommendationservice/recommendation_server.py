#!/usr/bin/env python3
#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import random
from concurrent import futures

import grpc
from grpc_health.v1 import health
from grpc_health.v1 import health_pb2
from grpc_health.v1 import health_pb2_grpc
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.grpc import GrpcInstrumentorClient
from opentelemetry.instrumentation.grpc import GrpcInstrumentorServer
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

import demo_pb2
import demo_pb2_grpc
from logger import get_json_logger


SERVICE_NAME = "avos-recommendationservice"
GRPC_SERVICE_NAME = "hipstershop.RecommendationService"
LOGGER = get_json_logger(SERVICE_NAME)


def _positive_number(name, default, number_type):
    raw_value = os.getenv(name, str(default))
    try:
        value = number_type(raw_value)
    except ValueError as exc:
        raise ValueError(f"{name} must be a valid {number_type.__name__}") from exc
    if value <= 0:
        raise ValueError(f"{name} must be greater than zero")
    return value


def configure_tracing():
    """Configure OTLP tracing when ENABLE_TRACING=1."""
    if os.getenv("ENABLE_TRACING", "0") != "1":
        LOGGER.info("Tracing disabled")
        return None

    provider = TracerProvider(
        resource=Resource.create({"service.name": SERVICE_NAME})
    )
    provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
    trace.set_tracer_provider(provider)
    GrpcInstrumentorClient().instrument()
    GrpcInstrumentorServer().instrument()
    LOGGER.info("OTLP tracing enabled")
    return provider


class RecommendationService(demo_pb2_grpc.RecommendationServiceServicer):
    """Return catalog products that are not already present in the request."""

    def __init__(
        self,
        product_catalog_stub,
        max_recommendations=5,
        catalog_timeout_seconds=3.0,
        randomizer=None,
    ):
        self._product_catalog_stub = product_catalog_stub
        self._max_recommendations = max_recommendations
        self._catalog_timeout_seconds = catalog_timeout_seconds
        self._randomizer = randomizer or random.SystemRandom()

    def ListRecommendations(self, request, context):
        try:
            catalog = self._product_catalog_stub.ListProducts(
                demo_pb2.Empty(), timeout=self._catalog_timeout_seconds
            )
        except grpc.RpcError as exc:
            LOGGER.warning(
                "Product Catalog request failed",
                extra={"grpc_status": str(exc.code())},
            )
            context.abort(
                grpc.StatusCode.UNAVAILABLE,
                "Product Catalog Service is unavailable",
            )

        excluded_ids = set(request.product_ids)
        eligible_ids = [
            product.id
            for product in catalog.products
            if product.id not in excluded_ids
        ]
        recommendation_count = min(self._max_recommendations, len(eligible_ids))
        recommendations = self._randomizer.sample(
            eligible_ids, recommendation_count
        )

        LOGGER.info(
            "Generated product recommendations",
            extra={
                "user_id": request.user_id,
                "recommendation_count": len(recommendations),
                "product_ids": recommendations,
            },
        )
        return demo_pb2.ListRecommendationsResponse(product_ids=recommendations)


def serve():
    port = _positive_number("PORT", 8080, int)
    max_workers = _positive_number("MAX_WORKERS", 10, int)
    max_recommendations = _positive_number("MAX_RECOMMENDATIONS", 5, int)
    catalog_timeout = _positive_number("CATALOG_TIMEOUT_SECONDS", 3.0, float)
    shutdown_grace = _positive_number("SHUTDOWN_GRACE_SECONDS", 5.0, float)

    catalog_address = os.getenv("PRODUCT_CATALOG_SERVICE_ADDR", "").strip()
    if not catalog_address:
        raise ValueError("PRODUCT_CATALOG_SERVICE_ADDR must be set")

    tracer_provider = configure_tracing()
    catalog_channel = grpc.insecure_channel(catalog_address)
    catalog_stub = demo_pb2_grpc.ProductCatalogServiceStub(catalog_channel)

    server = grpc.server(futures.ThreadPoolExecutor(max_workers=max_workers))
    service = RecommendationService(
        catalog_stub,
        max_recommendations=max_recommendations,
        catalog_timeout_seconds=catalog_timeout,
    )
    demo_pb2_grpc.add_RecommendationServiceServicer_to_server(service, server)

    health_service = health.HealthServicer()
    health_pb2_grpc.add_HealthServicer_to_server(health_service, server)
    health_service.set("", health_pb2.HealthCheckResponse.SERVING)
    health_service.set(GRPC_SERVICE_NAME, health_pb2.HealthCheckResponse.SERVING)

    bound_port = server.add_insecure_port(f"[::]:{port}")
    if bound_port == 0:
        raise RuntimeError(f"Unable to bind gRPC server to port {port}")

    server.start()
    LOGGER.info(
        "AVOS Recommendation Service started",
        extra={
            "port": port,
            "product_catalog_address": catalog_address,
            "max_recommendations": max_recommendations,
        },
    )

    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        LOGGER.info("Stopping AVOS Recommendation Service")
    finally:
        health_service.set("", health_pb2.HealthCheckResponse.NOT_SERVING)
        health_service.set(
            GRPC_SERVICE_NAME, health_pb2.HealthCheckResponse.NOT_SERVING
        )
        server.stop(shutdown_grace).wait()
        catalog_channel.close()
        if tracer_provider is not None:
            tracer_provider.shutdown()


if __name__ == "__main__":
    serve()
