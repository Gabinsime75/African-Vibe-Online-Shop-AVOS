#!/usr/bin/env bash
set -euo pipefail

PATH="${PATH}:$(go env GOPATH)/bin"
proto_dir="../../protos"
output_dir="./genproto"

mkdir -p "${output_dir}"
protoc \
  --proto_path="${proto_dir}" \
  --go_out="${output_dir}" \
  --go_opt=paths=source_relative \
  --go-grpc_out="${output_dir}" \
  --go-grpc_opt=paths=source_relative \
  "${proto_dir}/demo.proto"

echo "AVOS Checkout Service protobuf bindings regenerated."
