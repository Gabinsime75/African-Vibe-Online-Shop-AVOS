#!/usr/bin/env python3
# Copyright 2018 Google LLC
# Modifications copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

"""Small local gRPC client helper for the AVOS Email Service."""

import os

import grpc

import demo_pb2
import demo_pb2_grpc
from logger import get_json_logger


logger = get_json_logger("emailservice-client")


def send_confirmation_email(email, order):
    address = os.getenv("EMAIL_SERVICE_ADDR", "localhost:8080")
    with grpc.insecure_channel(address) as channel:
        stub = demo_pb2_grpc.EmailServiceStub(channel)
        try:
            stub.SendOrderConfirmation(
                demo_pb2.SendOrderConfirmationRequest(email=email, order=order),
                timeout=5,
            )
            logger.info("confirmation request completed")
        except grpc.RpcError as error:
            logger.error(
                "confirmation request failed",
                extra={"grpc_code": error.code().name},
            )
            raise


if __name__ == "__main__":
    logger.info("AVOS Email Service client helper loaded")
