#!/usr/bin/env bash
set -euo pipefail

# Generate the Python gRPC server bindings from the shared AVOS contract.
service_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proto_dir="${service_dir}/../../protos"

python -m grpc_tools.protoc \
  --proto_path="${proto_dir}" \
  --python_out="${service_dir}" \
  --grpc_python_out="${service_dir}" \
  "${proto_dir}/shoppingassistant.proto"
