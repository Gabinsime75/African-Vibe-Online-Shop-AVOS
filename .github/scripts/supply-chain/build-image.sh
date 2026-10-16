#!/usr/bin/env bash
set -euo pipefail

: "${SERVICE_NAME:?}"
: "${SOURCE_SHA:?}"
: "${BUILD_CONTEXT:?}"
: "${DOCKERFILE:?}"
: "${RUNNER_TEMP:?}"

evidence_dir="$RUNNER_TEMP/avos-supply-chain/$SERVICE_NAME"
mkdir -p "$evidence_dir"

docker buildx version > "$evidence_dir/buildx-version.txt"

export BUILDX_METADATA_PROVENANCE=max

docker buildx build \
  --load \
  --metadata-file "$evidence_dir/build-metadata.json" \
  --platform linux/amd64 \
  --file "$DOCKERFILE" \
  --tag "avos/$SERVICE_NAME:$SOURCE_SHA" \
  --label "org.opencontainers.image.revision=$SOURCE_SHA" \
  --label "org.opencontainers.image.source=$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" \
  "$BUILD_CONTEXT"
