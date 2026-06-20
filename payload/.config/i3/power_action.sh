#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
log_file="/tmp/stacki3-power-action.log"
exec >>"$log_file" 2>&1

echo "== $(date '+%F %T') power_action ${action} =="

run_privileged() {
  local verb="$1"

  if systemctl "$verb"; then
    return 0
  fi

  if command -v pkexec >/dev/null 2>&1; then
    pkexec /usr/bin/systemctl "$verb"
    return $?
  fi

  return 1
}

case "$action" in
  poweroff)
    run_privileged poweroff
    ;;
  reboot)
    run_privileged reboot
    ;;
  suspend)
    run_privileged suspend
    ;;
  lock)
    exec "$HOME/.config/i3/lock.sh"
    ;;
  logout)
    exec i3-msg exit
    ;;
  *)
    echo "usage: $0 {poweroff|reboot|suspend|lock|logout}"
    exit 2
    ;;
esac
