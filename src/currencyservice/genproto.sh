#!/usr/bin/env bash
set -euo pipefail

source_directory="../../protos"
destination_directory="./proto"

if [[ ! -d "${source_directory}" ]]; then
  echo "ERROR: Shared protobuf directory not found: ${source_directory}" >&2
  exit 1
fi

mkdir -p "${destination_directory}"
cp -R "${source_directory}/." "${destination_directory}/"

echo "AVOS Currency Service protobuf contracts synchronized."
