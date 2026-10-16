#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?}"

report_dir="$RUNNER_TEMP/avos-security/infrastructure"
raw_dir="$report_dir/raw"
mkdir -p "$raw_dir"

reports=()

for directory in terraform gitops; do
  test -d "$directory"

  if [[ "$directory" == "gitops" ]]; then
    configuration_file="$(
      find "$directory" -type f \
        ! -iname '*.md' \
        ! -name '.gitkeep' \
        -print -quit
    )"

    if [[ -z "$configuration_file" ]]; then
      echo "GitOps scan not applicable: directory contains documentation only."

      python3 - "$report_dir/gitops-coverage.json" <<'PY'
import json
from pathlib import Path
import sys

coverage = {
    "directory": "gitops",
    "status": "NOT_APPLICABLE",
    "reason": "Directory contains documentation only; no configuration to scan.",
}
Path(sys.argv[1]).write_text(
    json.dumps(coverage, indent=2) + "\n",
    encoding="utf-8",
)
PY
      continue
    fi
  fi

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

  reports+=("$raw_dir/$directory.json")
done

python3 .github/scripts/security/check-reports.py \
  --exceptions .github/scripts/security/infrastructure-exceptions.json \
  --output-dir "$report_dir" \
  "${reports[@]}"
