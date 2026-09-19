#!/usr/bin/env python3
"""African Vibe Online Shop AI shopping assistant gRPC service."""

from __future__ import annotations

import json
import logging
import os
import signal
from concurrent import futures
from dataclasses import dataclass
from typing import Any
from urllib.parse import urlparse

import boto3
import grpc
from botocore.config import Config as BotoConfig
from grpc_health.v1 import health, health_pb2, health_pb2_grpc
from opensearchpy import AWSV4SignerAuth, OpenSearch, RequestsHttpConnection
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

import shoppingassistant_pb2
import shoppingassistant_pb2_grpc


SERVICE_NAME = "avos.shoppingassistant.v1.ShoppingAssistantService"
SUPPORTED_IMAGE_TYPES = {
    "image/jpeg": "jpeg",
    "image/png": "png",
    "image/gif": "gif",
    "image/webp": "webp",
}


class JsonFormatter(logging.Formatter):
    """Formats service logs for Fluent Bit and CloudWatch ingestion."""

    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "severity": record.levelname,
            "service": "shoppingassistantservice",
            "message": record.getMessage(),
        }
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        return json.dumps(payload)


def configure_logging() -> logging.Logger:
    handler = logging.StreamHandler()
    handler.setFormatter(JsonFormatter())
    logger = logging.getLogger("avos.shoppingassistant")
    logger.handlers.clear()
    logger.addHandler(handler)
    logger.setLevel(os.getenv("LOG_LEVEL", "INFO").upper())
    logger.propagate = False
    return logger


LOGGER = configure_logging()


def configure_tracing() -> None:
    """Exports spans to the AVOS OpenTelemetry Collector when enabled."""
    if os.getenv("ENABLE_TRACING", "0") != "1":
        return
    provider = TracerProvider(
        resource=Resource.create({"service.name": "shoppingassistantservice"})
    )
    endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://otel-collector:4317")
    provider.add_span_processor(
        BatchSpanProcessor(
            OTLPSpanExporter(
                endpoint=endpoint,
                insecure=os.getenv("OTEL_EXPORTER_OTLP_INSECURE", "true").lower()
                == "true",
            )
        )
    )
    trace.set_tracer_provider(provider)


@dataclass(frozen=True)
class Settings:
    aws_region: str
    bedrock_model_id: str
    embedding_model_id: str
    opensearch_endpoint: str
    opensearch_index: str
    opensearch_service: str
    port: int
    top_k: int
    max_image_bytes: int
    request_timeout_seconds: int

    @classmethod
    def from_env(cls) -> "Settings":
        required = ("AWS_REGION", "BEDROCK_MODEL_ID", "OPENSEARCH_ENDPOINT")
        missing = [name for name in required if not os.getenv(name)]
        if missing:
            raise ValueError(f"missing required environment variables: {', '.join(missing)}")

        return cls(
            aws_region=os.environ["AWS_REGION"],
            bedrock_model_id=os.environ["BEDROCK_MODEL_ID"],
            embedding_model_id=os.getenv(
                "BEDROCK_EMBEDDING_MODEL_ID", "amazon.titan-embed-text-v2:0"
            ),
            opensearch_endpoint=os.environ["OPENSEARCH_ENDPOINT"],
            opensearch_index=os.getenv("OPENSEARCH_INDEX", "avos-products"),
            opensearch_service=os.getenv("OPENSEARCH_SERVICE", "es"),
            port=int(os.getenv("PORT", "8080")),
            top_k=max(1, min(int(os.getenv("RECOMMENDATION_LIMIT", "3")), 10)),
            max_image_bytes=int(os.getenv("MAX_IMAGE_BYTES", str(3 * 1024 * 1024))),
            request_timeout_seconds=int(os.getenv("AWS_REQUEST_TIMEOUT_SECONDS", "20")),
        )


@dataclass(frozen=True)
class RecommendationResult:
    content: str
    product_ids: list[str]


class AssistantEngine:
    """Runs the AVOS Bedrock and OpenSearch retrieval-augmented workflow."""

    def __init__(
        self,
        settings: Settings,
        bedrock_client: Any | None = None,
        search_client: Any | None = None,
    ) -> None:
        self.settings = settings
        self.bedrock = bedrock_client or self._build_bedrock_client()
        self.search = search_client or self._build_search_client()

    def _build_bedrock_client(self) -> Any:
        timeout = self.settings.request_timeout_seconds
        return boto3.client(
            "bedrock-runtime",
            region_name=self.settings.aws_region,
            config=BotoConfig(
                connect_timeout=timeout,
                read_timeout=timeout,
                retries={"max_attempts": 3, "mode": "standard"},
            ),
        )

    def _build_search_client(self) -> OpenSearch:
        endpoint = self.settings.opensearch_endpoint
        parsed = urlparse(endpoint if "://" in endpoint else f"https://{endpoint}")
        if not parsed.hostname:
            raise ValueError("OPENSEARCH_ENDPOINT must contain a valid hostname")

        session = boto3.Session(region_name=self.settings.aws_region)
        credentials = session.get_credentials()
        if credentials is None:
            raise RuntimeError("AWS credentials were not available from the workload identity")

        auth = AWSV4SignerAuth(
            credentials,
            self.settings.aws_region,
            self.settings.opensearch_service,
        )
        return OpenSearch(
            hosts=[{"host": parsed.hostname, "port": parsed.port or 443}],
            http_auth=auth,
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection,
            pool_maxsize=20,
        )

    def recommend(
        self,
        prompt: str,
        image: bytes,
        image_media_type: str,
    ) -> RecommendationResult:
        room_description = self._describe_image(image, image_media_type) if image else ""
        retrieval_text = "\n".join(
            part for part in (prompt, room_description) if part
        ).strip()
        embedding = self._embed(retrieval_text)
        products = self._search_products(embedding)
        content = self._compose_response(prompt, room_description, products)
        product_ids = [str(product["id"]) for product in products if product.get("id")]
        return RecommendationResult(content=content, product_ids=product_ids)

    def _describe_image(self, image: bytes, media_type: str) -> str:
        image_format = SUPPORTED_IMAGE_TYPES[media_type]
        content = [
            {
                "text": (
                    "Describe the visible style, colors, materials, and practical shopping "
                    "needs in this image. Do not identify people or infer sensitive traits."
                )
            },
            {"image": {"format": image_format, "source": {"bytes": image}}},
        ]
        return self._converse(content, max_tokens=350)

    def _embed(self, text: str) -> list[float]:
        response = self.bedrock.invoke_model(
            modelId=self.settings.embedding_model_id,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(
                {"inputText": text, "dimensions": 1024, "normalize": True}
            ),
        )
        payload = json.loads(response["body"].read())
        embedding = payload.get("embedding")
        if not isinstance(embedding, list) or not embedding:
            raise RuntimeError("Bedrock embedding response did not contain an embedding")
        return embedding

    def _search_products(self, embedding: list[float]) -> list[dict[str, Any]]:
        response = self.search.search(
            index=self.settings.opensearch_index,
            body={
                "size": self.settings.top_k,
                "_source": ["id", "name", "description", "categories", "picture"],
                "query": {
                    "knn": {
                        "product_embedding": {
                            "vector": embedding,
                            "k": self.settings.top_k,
                        }
                    }
                },
            },
        )
        hits = response.get("hits", {}).get("hits", [])
        return [hit.get("_source", {}) for hit in hits if hit.get("_source")]

    def _compose_response(
        self,
        prompt: str,
        room_description: str,
        products: list[dict[str, Any]],
    ) -> str:
        if not products:
            return (
                "I could not find a close match in the current AVOS catalog. "
                "Try describing the product, color, material, or style you want."
            )

        catalog_context = json.dumps(products, ensure_ascii=False)
        request_text = (
            "You are the African Vibe Online Shop (AVOS) shopping assistant. "
            "Recommend only products supplied in CATALOG_RESULTS. Never invent products, "
            "prices, product IDs, availability, or cultural provenance. Keep the answer "
            "helpful and concise. Product IDs are returned separately by the application, "
            "so do not print IDs or bracketed codes in your answer.\n\n"
            f"CUSTOMER_REQUEST:\n{prompt or 'Suggest suitable AVOS products.'}\n\n"
            f"IMAGE_DESCRIPTION:\n{room_description or 'No image was provided.'}\n\n"
            f"CATALOG_RESULTS:\n{catalog_context}"
        )
        return self._converse([{"text": request_text}], max_tokens=650)

    def _converse(self, content: list[dict[str, Any]], max_tokens: int) -> str:
        response = self.bedrock.converse(
            modelId=self.settings.bedrock_model_id,
            messages=[{"role": "user", "content": content}],
            inferenceConfig={
                "maxTokens": max_tokens,
                "temperature": 0.2,
                "topP": 0.9,
            },
        )
        blocks = response.get("output", {}).get("message", {}).get("content", [])
        text = "\n".join(block["text"] for block in blocks if block.get("text"))
        if not text:
            raise RuntimeError("Bedrock response did not contain text")
        return text.strip()


class ShoppingAssistantServicer(
    shoppingassistant_pb2_grpc.ShoppingAssistantServiceServicer
):
    def __init__(self, engine: AssistantEngine, max_image_bytes: int) -> None:
        self.engine = engine
        self.max_image_bytes = max_image_bytes

    def GetRecommendations(self, request, context):  # noqa: N802
        prompt = request.prompt.strip()
        image = bytes(request.image)
        media_type = request.image_media_type.lower().strip()

        if not prompt and not image:
            context.abort(grpc.StatusCode.INVALID_ARGUMENT, "prompt or image is required")
        if len(image) > self.max_image_bytes:
            context.abort(grpc.StatusCode.RESOURCE_EXHAUSTED, "image exceeds size limit")
        if image and media_type not in SUPPORTED_IMAGE_TYPES:
            context.abort(
                grpc.StatusCode.INVALID_ARGUMENT,
                "image_media_type must be image/jpeg, image/png, image/gif, or image/webp",
            )

        try:
            with trace.get_tracer(__name__).start_as_current_span(
                "shoppingassistant.get_recommendations"
            ) as span:
                span.set_attribute("assistant.image_supplied", bool(image))
                result = self.engine.recommend(prompt, image, media_type)
                span.set_attribute("assistant.product_count", len(result.product_ids))
        except Exception:
            LOGGER.exception("assistant recommendation failed")
            context.abort(grpc.StatusCode.UNAVAILABLE, "assistant dependencies are unavailable")

        LOGGER.info(
            "recommendation completed user_id=%s product_count=%d image_supplied=%s",
            request.user_id or "anonymous",
            len(result.product_ids),
            bool(image),
        )
        return shoppingassistant_pb2.ShoppingAssistantResponse(
            content=result.content,
            product_ids=result.product_ids,
        )


def create_server(settings: Settings, engine: AssistantEngine | None = None) -> grpc.Server:
    server = grpc.server(
        futures.ThreadPoolExecutor(max_workers=int(os.getenv("GRPC_WORKERS", "10"))),
        options=[
            ("grpc.max_receive_message_length", settings.max_image_bytes + 512 * 1024),
            ("grpc.max_send_message_length", 1024 * 1024),
        ],
    )
    assistant = ShoppingAssistantServicer(
        engine or AssistantEngine(settings), settings.max_image_bytes
    )
    shoppingassistant_pb2_grpc.add_ShoppingAssistantServiceServicer_to_server(
        assistant, server
    )

    health_service = health.HealthServicer()
    health_pb2_grpc.add_HealthServicer_to_server(health_service, server)
    health_service.set("", health_pb2.HealthCheckResponse.SERVING)
    health_service.set(SERVICE_NAME, health_pb2.HealthCheckResponse.SERVING)

    server.add_insecure_port(f"[::]:{settings.port}")
    return server


def serve() -> None:
    configure_tracing()
    settings = Settings.from_env()
    server = create_server(settings)
    server.start()
    LOGGER.info("AVOS Shopping Assistant gRPC server listening on port %d", settings.port)

    def stop_server(signum, _frame):
        LOGGER.info("received signal %d; stopping server", signum)
        server.stop(grace=10)

    signal.signal(signal.SIGTERM, stop_server)
    signal.signal(signal.SIGINT, stop_server)
    server.wait_for_termination()


if __name__ == "__main__":
    serve()
