#!/usr/bin/env sh
set -eu

frontend_address="${FRONTEND_ADDR:-frontend:80}"
users="${USERS:-10}"
spawn_rate="${RATE:-1}"
run_time="${RUN_TIME:-}"
log_level="${LOCUST_LOGLEVEL:-INFO}"

case "$frontend_address" in
  http://*|https://*) target_url="$frontend_address" ;;
  *) target_url="http://$frontend_address" ;;
esac

case "$users" in
  ''|*[!0-9]*) echo "USERS must be a positive integer" >&2; exit 1 ;;
esac
if [ "$users" -lt 1 ]; then
  echo "USERS must be a positive integer" >&2
  exit 1
fi

case "$spawn_rate" in
  ''|*[!0-9.]*) echo "RATE must be a positive number" >&2; exit 1 ;;
esac
if ! awk "BEGIN { exit !($spawn_rate > 0) }" 2>/dev/null; then
  echo "RATE must be a positive number" >&2
  exit 1
fi

set -- locust \
  --host "$target_url" \
  --headless \
  --users "$users" \
  --spawn-rate "$spawn_rate" \
  --loglevel "$log_level"

if [ -n "$run_time" ]; then
  set -- "$@" --run-time "$run_time"
fi

exec "$@"
