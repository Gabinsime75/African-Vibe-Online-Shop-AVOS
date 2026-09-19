#!/usr/bin/env python3
# Copyright 2018 Google LLC
# Modifications copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

"""Simulated order-confirmation email service for AVOS."""

from concurrent import futures
from email.utils import parseaddr
import os
from pathlib import Path
import re
import signal
import threading

import grpc
from grpc_health.v1 import health, health_pb2, health_pb2_grpc
from jinja2 import Environment, FileSystemLoader, StrictUndefined, TemplateError, select_autoescape
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.grpc import GrpcInstrumentorServer
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

import demo_pb2
import demo_pb2_grpc
from logger import get_json_logger


DEFAULT_PORT = 8080
MAX_MESSAGE_BYTES = 1024 * 1024
EMAIL_PATTERN = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
TEMPLATE_DIRECTORY = Path(__file__).resolve().parent / "templates"

logger = get_json_logger("emailservice")
template_environment = Environment(
    loader=FileSystemLoader(TEMPLATE_DIRECTORY),
    autoescape=select_autoescape(["html", "xml"]),
    undefined=StrictUndefined,
)


def environment_flag(name, fallback):
    value = os.getenv(name)
    if value is None or not value.strip():
        return fallback
    return value.strip().lower() in {"1", "true", "yes"}


def configured_port():
    value = os.getenv("PORT", str(DEFAULT_PORT))
    try:
        port = int(value)
    except ValueError as error:
        raise ValueError("PORT must be an integer between 1 and 65535") from error
    if not 1 <= port <= 65535:
        raise ValueError("PORT must be between 1 and 65535")
    return port


def validate_email_address(value):
    address = value.strip() if isinstance(value, str) else ""
    parsed = parseaddr(address)[1]
    if len(address) > 254 or parsed != address or not EMAIL_PATTERN.fullmatch(address):
        raise ValueError("a valid customer email address is required")
    return address


def validate_confirmation_request(request):
    email_address = validate_email_address(request.email)
    if not request.HasField("order"):
        raise ValueError("order is required")
    order = request.order
    if not order.order_id.strip():
        raise ValueError("order.order_id is required")
    if not order.shipping_tracking_id.strip():
        raise ValueError("order.shipping_tracking_id is required")
    if not order.HasField("shipping_cost"):
        raise ValueError("order.shipping_cost is required")
    if not order.HasField("shipping_address"):
        raise ValueError("order.shipping_address is required")
    return email_address, order


def format_money(money):
    nanos = abs(int(money.nanos))
    cents = nanos // 10_000_000
    sign = "-" if int(money.units) < 0 or int(money.nanos) < 0 else ""
    units = abs(int(money.units))
    return f"{sign}{units}.{cents:02d} {money.currency_code}"


template_environment.filters["money"] = format_money
confirmation_template = template_environment.get_template("confirmation.html")


def render_confirmation(order):
    return confirmation_template.render(order=order)


class EmailService(demo_pb2_grpc.EmailServiceServicer):
    """Validates and renders an order confirmation without external delivery."""

    def SendOrderConfirmation(self, request, context):
        try:
            email_address, order = validate_confirmation_request(request)
        except ValueError as error:
            context.abort(grpc.StatusCode.INVALID_ARGUMENT, str(error))

        try:
            confirmation = render_confirmation(order)
        except TemplateError:
            logger.exception("order confirmation rendering failed")
            context.abort(grpc.StatusCode.INTERNAL, "order confirmation could not be prepared")

        # Phase 1 simulates delivery. Never log the email address or postal address.
        logger.info(
            "simulated order confirmation prepared",
            extra={
                "order_id": order.order_id,
                "recipient_domain": email_address.rsplit("@", 1)[1].lower(),
                "rendered_bytes": len(confirmation.encode("utf-8")),
            },
        )
        return demo_pb2.Empty()


def configure_telemetry():
    if not environment_flag("ENABLE_OTEL", True):
        logger.info("OpenTelemetry disabled")
        return None

    resource = Resource.create(
        {
            "service.name": "emailservice",
            "service.namespace": "avos",
            "service.version": "1.0.0",
        }
    )
    provider = TracerProvider(resource=resource)
    provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
    trace.set_tracer_provider(provider)
    GrpcInstrumentorServer().instrument()
    logger.info("OpenTelemetry enabled")
    return provider


def create_server():
    server = grpc.server(
        futures.ThreadPoolExecutor(max_workers=10),
        options=(
            ("grpc.max_receive_message_length", MAX_MESSAGE_BYTES),
            ("grpc.max_send_message_length", MAX_MESSAGE_BYTES),
        ),
    )
    demo_pb2_grpc.add_EmailServiceServicer_to_server(EmailService(), server)

    health_service = health.HealthServicer()
    health_service.set("", health_pb2.HealthCheckResponse.SERVING)
    health_pb2_grpc.add_HealthServicer_to_server(health_service, server)
    return server, health_service


def serve():
    port = configured_port()
    tracer_provider = configure_telemetry()
    server, health_service = create_server()
    bound_port = server.add_insecure_port(f"[::]:{port}")
    if bound_port == 0:
        raise RuntimeError(f"failed to bind gRPC server on port {port}")

    stop_event = threading.Event()

    def request_shutdown(signum, _frame):
        logger.info("shutdown requested", extra={"signal": signum})
        stop_event.set()

    signal.signal(signal.SIGINT, request_shutdown)
    signal.signal(signal.SIGTERM, request_shutdown)

    server.start()
    logger.info("AVOS Email Service listening", extra={"port": bound_port})
    stop_event.wait()

    health_service.set("", health_pb2.HealthCheckResponse.NOT_SERVING)
    server.stop(grace=10).wait()
    if tracer_provider is not None:
        tracer_provider.shutdown()


if __name__ == "__main__":
    serve()
