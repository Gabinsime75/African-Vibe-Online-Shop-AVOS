#!/usr/bin/env bash
set -euo pipefail

service_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared_proto_dir="$service_dir/../../protos"

if [[ ! -d "$shared_proto_dir" ]]; then
  echo "Shared protobuf directory not found: $shared_proto_dir" >&2
  exit 1
fi

mkdir -p "$service_dir/proto"
cp -R "$shared_proto_dir/." "$service_dir/proto/"
echo "Payment Service protobuf files synchronized."
