#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
cleanup() {
  exit_code=$?
  if (( exit_code != 0 )); then
    echo "Smoke test failed; collecting bounded diagnostics"
    docker compose -p linux-troubleshooting-lab ps || true
    docker compose -p linux-troubleshooting-lab logs --tail=100 backend proxy toolbox || true
  fi
  docker compose -p linux-troubleshooting-lab down --remove-orphans >/dev/null 2>&1 || true
}
wait_for_health() {
  local _
  for _ in $(seq 1 30); do
    if curl -fsS --max-time 2 http://127.0.0.1:8080/health/ready | grep -q ready; then
      return 0
    fi
    sleep 2
  done
  echo "Health endpoint did not become ready after 60 seconds" >&2
  return 1
}
trap cleanup EXIT INT TERM
timeout 180 docker compose -p linux-troubleshooting-lab up -d --build
wait_for_health
./lab.sh start 12
./lab.sh verify 12
./lab.sh reset 12
wait_for_health
