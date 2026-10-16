#!/usr/bin/env bash
set -euo pipefail

version="0.75.0"
checksum="c6e65abddb348e25f10549df887045629cf28cc72453cd1c63acb717316b3f3f"

install_dir="${RUNNER_TEMP:?}/avos-tools/trivy"
download_dir="$(mktemp -d)"
trap 'rm -rf -- "$download_dir"' EXIT

archive="$download_dir/trivy.tar.gz"

curl --fail --silent --show-error --location \
  --retry 3 \
  "https://github.com/aquasecurity/trivy/releases/download/v${version}/trivy_${version}_Linux-64bit.tar.gz" \
  --output "$archive"

printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check -

mkdir -p "$install_dir"
tar -xzf "$archive" -C "$install_dir" trivy
chmod 0755 "$install_dir/trivy"

"$install_dir/trivy" --version

printf '%s\n' "$install_dir" >> "${GITHUB_PATH:?}"
