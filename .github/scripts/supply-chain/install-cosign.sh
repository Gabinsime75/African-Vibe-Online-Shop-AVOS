#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?RUNNER_TEMP is required}"
: "${GITHUB_PATH:?GITHUB_PATH is required}"

version="3.1.3"
expected_sha256="4629c757b7618056f8ddd7e2625ae9fdd94c0372a65049520bc7d9df9efc7f71"

if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
  echo "::error::This installer requires Linux x86_64."
  exit 1
fi

download_dir="$(mktemp -d "$RUNNER_TEMP/avos-cosign.XXXXXX")"
trap 'rm -rf -- "$download_dir"' EXIT

curl \
  --fail \
  --silent \
  --show-error \
  --location \
  --retry 3 \
  --proto '=https' \
  --tlsv1.2 \
  --output "$download_dir/cosign" \
  "https://github.com/sigstore/cosign/releases/download/v${version}/cosign-linux-amd64"

printf '%s  %s\n' \
  "$expected_sha256" \
  "$download_dir/cosign" |
  sha256sum --check --strict

install_dir="$RUNNER_TEMP/avos-tools/cosign"
mkdir -p "$install_dir"

install -m 0755 "$download_dir/cosign" "$install_dir/cosign"
echo "$install_dir" >> "$GITHUB_PATH"

"$install_dir/cosign" version
