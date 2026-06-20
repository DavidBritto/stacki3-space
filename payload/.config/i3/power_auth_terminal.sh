#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
LOG_FILE="/tmp/power-auth-terminal.log"
exec >>"$LOG_FILE" 2>&1

echo "== $(date '+%F %T') power_auth_terminal $action =="

run_with_agent() {
  local cmd="$1"
  local fifo pid
  fifo="$(mktemp -u)"
  mkfifo "$fifo"
  pkttyagent --process $$ --notify-fd 3 3>"$fifo" --fallback &
  pid=$!
  read -r _ <"$fifo" || true
  rm -f "$fifo"
  echo "+ $cmd"
  bash -lc "$cmd"
  local rc=$?
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  return $rc
}

case "$action" in
  poweroff)
    run_with_agent 'systemctl poweroff || poweroff || shutdown -h now'
    ;;
  reboot)
    run_with_agent 'systemctl reboot || reboot'
    ;;
  *)
    echo "usage: $0 {poweroff|reboot}"
    exit 2
    ;;
esac
