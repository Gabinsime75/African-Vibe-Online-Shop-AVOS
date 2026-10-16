#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?}"

report_dir="$RUNNER_TEMP/avos-security/infrastructure"
raw_dir="$report_dir/raw"
mkdir -p "$raw_dir"

for directory in terraform gitops; do
  test -d "$directory"

  trivy config \
    --config "" \
    --ignorefile "" \
    --skip-dirs '**/.terraform' \
    --skip-dirs '**/node_modules' \
    --skip-dirs '**/.venv' \
    --timeout 10m \
    --exit-code 0 \
    --format json \
    --output "$raw_dir/$directory.json" \
    "$directory"
done

python3 .github/scripts/security/check-reports.py \
  --output-dir "$report_dir" \
  "$raw_dir/terraform.json" \
  "$raw_dir/gitops.json"
