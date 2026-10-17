#!/usr/bin/env bash
# Wait until the root app and every child Application report Synced.
set -euo pipefail
expected="${EXPECTED_APPS:-root web-service-dev web-service-staging web-service-prod}"
deadline=$(( $(date +%s) + ${TIMEOUT_SECONDS:-600} ))
while :; do
  pending=""
  for app in $expected; do
    s="$(kubectl -n argocd get application "$app" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
    [ "$s" = "Synced" ] || pending="$pending $app(${s:-missing})"
  done
  if [ -z "$pending" ]; then
    echo "all applications synced"; kubectl -n argocd get applications; exit 0
  fi
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "timed out waiting for:$pending"; exit 1
  fi
  echo "waiting:$pending"; sleep 10
done
