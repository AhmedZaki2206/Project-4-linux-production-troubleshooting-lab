#!/usr/bin/env bash
set -Eeuo pipefail

action=${1:?action required}
id=${2:?incident ID required}
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
dc=(docker compose -p linux-troubleshooting-lab)

baseline() { "${dc[@]}" up -d --remove-orphans; }
reset_lab() {
  HOST_PORT=8080 "${dc[@]}" -f compose.yaml down --remove-orphans >/dev/null 2>&1 || true
  docker rm -f linux-troubleshooting-lab-port-owner >/dev/null 2>&1 || true
  rm -f .lab-state/fault-compose
  baseline
}
fault_up() {
  local file=$1
  printf '%s\n' "$file" >.lab-state/fault-compose
  "${dc[@]}" -f compose.yaml -f "$file" up -d --force-recreate
}

if [[ $action == reset ]]; then reset_lab; exit 0; fi

if [[ $action == verify ]]; then
  case "$id" in
    01) "${dc[@]}" exec -T backend sh -c "ps | grep '[c]pu-burn'" >/dev/null ;;
    02) "${dc[@]}" exec -T backend sh -c "ps | grep '[m]emory-pressure'" >/dev/null ;;
    03) "${dc[@]}" exec -T backend test -f /tmp/disk-full ;;
    04) "${dc[@]}" exec -T backend test -d /tmp/inodes ;;
    05|12) ! "${dc[@]}" ps --status running --services | grep -qx backend ;;
    06) "${dc[@]}" exec -T -u 101 proxy test ! -r /var/log/nginx/access.log ;;
    07) docker ps --format '{{.Names}}' | grep -qx linux-troubleshooting-lab-port-owner ;;
    08) [[ $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/) == 500 ]] ;;
    09|17) ! "${dc[@]}" exec -T toolbox nslookup backend >/dev/null 2>&1 ;;
    10|11|19) echo "VM-ONLY: follow docs/SOLUTIONS.md and verify inside the disposable VM."; exit 2 ;;
    13) [[ $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/) == 502 ]] ;;
    14) [[ $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/) == 503 ]] ;;
    15) ! "${dc[@]}" exec -T proxy nginx -t >/dev/null 2>&1 ;;
    16) [[ $("${dc[@]}" ps backend --format json | grep -c restarting) -gt 0 ]] ;;
    18) ! curl -fsS --max-time 2 http://127.0.0.1:8080/health/ready >/dev/null ;;
    20) "${dc[@]}" exec -T -u 101 proxy test ! -w /var/log/nginx ;;
  esac
  echo "Incident $id fault is observable. This verifies injection, not recovery."
  exit 0
fi

baseline
case "$id" in
  01) "${dc[@]}" exec -d backend sh -c "exec -a cpu-burn python -c 'while True: pass'" ;;
  02) "${dc[@]}" exec -d backend sh -c "exec -a memory-pressure python -c 'import time; x=bytearray(90*1024*1024); time.sleep(300)'" ;;
  03) "${dc[@]}" exec -T backend sh -c "dd if=/dev/zero of=/tmp/disk-full bs=1M count=15 2>/dev/null || true" ;;
  04) "${dc[@]}" exec -T backend sh -c "mkdir -p /tmp/inodes; i=0; while [ \$i -lt 4000 ]; do : > /tmp/inodes/f\$i; i=\$((i+1)); done" ;;
  05|12) "${dc[@]}" stop backend ;;
  06) "${dc[@]}" exec -T -u 0 proxy chmod 000 /var/log/nginx/access.log ;;
  07)
    "${dc[@]}" stop proxy
    docker run -d --name linux-troubleshooting-lab-port-owner --label project=linux-troubleshooting-lab -p 127.0.0.1:8080:80 --memory=32m --cpus=.10 nginx:1.27-alpine >/dev/null
    ;;
  08) fault_up faults/missing-env.yaml ;;
  09|17) fault_up faults/dns-failure.yaml ;;
  10|11|19) echo "Incident $id is VM-ONLY. See docs/HANDS_ON_LABS.md."; exit 0 ;;
  13) fault_up faults/proxy-502.yaml ;;
  14) fault_up faults/proxy-503.yaml ;;
  15) fault_up faults/proxy-broken.yaml ;;
  16) fault_up faults/crash-loop.yaml ;;
  18) HOST_PORT=8081 "${dc[@]}" up -d --force-recreate ;;
  20) "${dc[@]}" exec -T -u 0 proxy chmod 500 /var/log/nginx ;;
esac
echo "Incident $id started. Investigate before reading docs/SOLUTIONS.md."
