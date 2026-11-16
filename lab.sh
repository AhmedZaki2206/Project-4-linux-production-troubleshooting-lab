#!/usr/bin/env bash
set -Eeuo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
state="$root/.lab-state"
catalog="$root/incidents/catalog.tsv"
mkdir -p "$state"

usage() { echo "Usage: ./lab.sh {list|start ID|status|hint ID|verify ID|reset ID|reset-all}"; }
valid() { grep -q "^$1[[:space:]]" "$catalog"; }
active() {
  if [[ -f $state/active ]]; then
    cat "$state/active"
  fi
}

cmd=${1:-}
case "$cmd" in
  list) column -t -s $'\t' "$catalog" 2>/dev/null || cat "$catalog" ;;
  start)
    id=${2:-}; valid "$id" || { echo "Invalid incident ID: $id" >&2; exit 64; }
    current=$(active); [[ -z $current || $current == "$id" ]] || { echo "Reset active incident $current first." >&2; exit 65; }
    trap 'echo "Start interrupted; run ./lab.sh reset-all" >&2' INT TERM
    "$root/scripts/incident-action.sh" start "$id"
    printf '%s\n' "$id" >"$state/active"
    ;;
  status)
    echo "Active incident: $(active)"; docker compose -p linux-troubleshooting-lab ps 2>/dev/null || true ;;
  hint)
    id=${2:-}; valid "$id" || exit 64
    grep "^$id|" "$root/incidents/hints.txt" | cut -d'|' -f2-
    ;;
  verify)
    id=${2:-}; valid "$id" || exit 64
    "$root/scripts/incident-action.sh" verify "$id"
    ;;
  reset)
    id=${2:-}; valid "$id" || exit 64
    "$root/scripts/incident-action.sh" reset "$id"; rm -f "$state/active"; echo "Lab reset to baseline." ;;
  reset-all)
    "$root/scripts/incident-action.sh" reset 00; rm -rf "$state"; mkdir -p "$state"; echo "All project-owned faults reset." ;;
  *) usage; exit 64 ;;
esac
