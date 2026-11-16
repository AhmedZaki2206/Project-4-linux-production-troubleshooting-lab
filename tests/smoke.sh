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
  ./lab.sh reset-all >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM
timeout 180 docker compose -p linux-troubleshooting-lab up -d --build
for _ in $(seq 1 30); do
  curl -fsS --max-time 2 http://127.0.0.1:8080/health/ready >/dev/null && break
  sleep 2
done
curl -fsS --max-time 3 http://127.0.0.1:8080/health/ready | grep -q ready
./lab.sh start 12
./lab.sh verify 12
./lab.sh reset 12
curl -fsS --max-time 3 http://127.0.0.1:8080/health/ready >/dev/null
