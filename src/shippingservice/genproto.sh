#!/usr/bin/env bash
set -euo pipefail

service_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proto_dir="$service_dir/../../protos"
output_dir="$service_dir/genproto"

if [[ ! -f "$proto_dir/demo.proto" ]]; then
	echo "Shared protobuf file not found: $proto_dir/demo.proto" >&2
	exit 1
fi

export PATH="$PATH:$(go env GOPATH)/bin"
mkdir -p "$output_dir"

protoc \
	--proto_path="$proto_dir" \
	--go_out="$output_dir" \
	--go_opt=paths=source_relative \
	--go-grpc_out="$output_dir" \
	--go-grpc_opt=paths=source_relative \
	"$proto_dir/demo.proto"

echo "Shipping Service protobuf files regenerated."
