#!/usr/bin/env bash
set -euo pipefail

service_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proto_file="$service_dir/../../protos/demo.proto"

if [[ ! -f "$proto_file" ]]; then
  echo "Shared protobuf file not found: $proto_file" >&2
  exit 1
fi

python -m grpc_tools.protoc \
  -I"$(dirname "$proto_file")" \
  --python_out="$service_dir" \
  --grpc_python_out="$service_dir" \
  "$proto_file"

echo "Email Service protobuf files regenerated."
