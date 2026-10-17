#!/usr/bin/env bash
set -euo pipefail

: "${SERVICE_NAME:?}"
: "${SERVICE_PATH:?}"
: "${SOURCE_SHA:?}"
: "${RUNNER_TEMP:?}"

report_dir="$RUNNER_TEMP/avos-security/$SERVICE_NAME"
raw_dir="$report_dir/raw"
mkdir -p "$raw_dir"

image="avos/$SERVICE_NAME:$SOURCE_SHA"
image_id="$(docker image inspect --format '{{.Id}}' "$image")"

echo "Scanning service: $SERVICE_NAME"
echo "Local image ID: $image_id"

trivy fs \
  --config "" \
  --ignorefile "" \
  --scanners vuln,secret,misconfig \
  --include-dev-deps \
  --skip-dirs '**/node_modules' \
  --skip-dirs '**/.venv' \
  --skip-dirs '**/.terraform' \
  --timeout 10m \
  --exit-code 0 \
  --format json \
  --output "$raw_dir/filesystem.json" \
  "$SERVICE_PATH"

trivy image \
  --config "" \
  --ignorefile "" \
  --image-src docker \
  --scanners vuln,secret \
  --image-config-scanners secret \
  --timeout 10m \
  --exit-code 0 \
  --format json \
  --output "$raw_dir/image.json" \
  "$image_id"

python3 .github/scripts/security/check-reports.py \
  --output-dir "$report_dir" \
  "$raw_dir/filesystem.json" \
  "$raw_dir/image.json"
