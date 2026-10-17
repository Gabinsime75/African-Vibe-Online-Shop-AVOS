#!/usr/bin/env bash
set -euo pipefail

: "${SERVICE_NAME:?}"
: "${SOURCE_SHA:?}"
: "${BUILD_CONTEXT:?}"
: "${DOCKERFILE:?}"
: "${RUNNER_TEMP:?}"
: "${GITHUB_OUTPUT:?}"

if [[ ! "$SOURCE_SHA" =~ ^[0-9a-f]{40}$ ]]; then
  echo "::error::SOURCE_SHA must be a full 40-character commit SHA."
  exit 1
fi

if [[ "$(git rev-parse HEAD)" != "$SOURCE_SHA" ]]; then
  echo "::error::SOURCE_SHA does not match the checked-out commit."
  exit 1
fi

evidence_dir="$RUNNER_TEMP/avos-supply-chain/$SERVICE_NAME"
mkdir -p "$evidence_dir"

image="avos/$SERVICE_NAME:$SOURCE_SHA"

docker buildx version > "$evidence_dir/buildx-version.txt"

export BUILDX_METADATA_PROVENANCE=max

docker buildx build \
  --load \
  --metadata-file "$evidence_dir/build-metadata.json" \
  --platform linux/amd64 \
  --file "$DOCKERFILE" \
  --tag "$image" \
  --label "org.opencontainers.image.revision=$SOURCE_SHA" \
  --label "org.opencontainers.image.source=$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" \
  "$BUILD_CONTEXT"

image_id="$(docker image inspect --format '{{.Id}}' "$image")"

python3 - "$evidence_dir/build-metadata.json" "$image_id" <<'PY'
import json
from pathlib import Path
import re
import sys

metadata = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
image_id = sys.argv[2]

if not re.fullmatch(r"sha256:[0-9a-f]{64}", image_id):
    raise SystemExit("Invalid local image ID.")
if metadata.get("containerimage.config.digest") != image_id:
    raise SystemExit("Tagged image does not match the build metadata.")

print("PASS: SHA-tagged image matches the build metadata.")
PY

{
  echo "image-tag=$SOURCE_SHA"
  echo "local-image=$image"
  echo "image-id=$image_id"
} >> "$GITHUB_OUTPUT"
