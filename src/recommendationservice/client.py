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

import argparse

import grpc

import demo_pb2
import demo_pb2_grpc
from logger import get_json_logger


LOGGER = get_json_logger("avos-recommendationservice-client")


def main():
    parser = argparse.ArgumentParser(
        description="Call the AVOS Recommendation Service"
    )
    parser.add_argument("--address", default="localhost:8080")
    parser.add_argument("--user-id", default="local-test-user")
    parser.add_argument("--product-id", action="append", default=[])
    parser.add_argument("--timeout", type=float, default=5.0)
    args = parser.parse_args()

    with grpc.insecure_channel(args.address) as channel:
        grpc.channel_ready_future(channel).result(timeout=args.timeout)
        stub = demo_pb2_grpc.RecommendationServiceStub(channel)
        response = stub.ListRecommendations(
            demo_pb2.ListRecommendationsRequest(
                user_id=args.user_id,
                product_ids=args.product_id,
            ),
            timeout=args.timeout,
        )

    LOGGER.info(
        "Received recommendations",
        extra={"product_ids": list(response.product_ids)},
    )


if __name__ == "__main__":
    main()
