#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
failed=0
check() { echo "==> $*"; "$@" || failed=1; }
check bash -n lab.sh scripts/incident-action.sh tests/run-safe-tests.sh tests/smoke.sh
if command -v shellcheck >/dev/null; then check shellcheck lab.sh scripts/*.sh tests/*.sh; else echo "NOT RUN: ShellCheck is not installed"; fi
if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
  check docker compose config --quiet
  check tests/smoke.sh
else
  echo "NOT RUN: Docker Engine is unavailable"
fi
exit "$failed"
