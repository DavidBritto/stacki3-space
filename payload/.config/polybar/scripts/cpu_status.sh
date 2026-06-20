#!/usr/bin/env bash

set -euo pipefail

CACHE_FILE="/tmp/polybar-cpu-status-${UID}.cache"

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total_now=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_now=$((idle + iowait))

if [ -f "$CACHE_FILE" ]; then
  read -r total_prev idle_prev < "$CACHE_FILE" || true
else
  total_prev=""
  idle_prev=""
fi

printf '%s %s\n' "$total_now" "$idle_now" > "$CACHE_FILE"

if ! [[ "${total_prev:-}" =~ ^[0-9]+$ ]] || ! [[ "${idle_prev:-}" =~ ^[0-9]+$ ]]; then
  used_pct=0
else
  total_diff=$((total_now - total_prev))
  idle_diff=$((idle_now - idle_prev))

  if [ "$total_diff" -le 0 ]; then
    used_pct=0
  else
    used_pct=$(( (100 * (total_diff - idle_diff)) / total_diff ))
  fi
fi

printf 'CPU %3d%% |\n' "$used_pct"
