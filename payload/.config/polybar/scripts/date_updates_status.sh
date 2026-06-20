#!/usr/bin/env bash
set -euo pipefail

calendar_cmd="__STACKI3_SPACE_HOME__/.config/polybar/scripts/calendar_tui.sh"
updates_cmd="__STACKI3_SPACE_HOME__/.local/bin/space menu system"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/stacki3-space/updates-count"
mkdir -p "$(dirname "$cache")"

update_count() {
  local now mtime raw count
  now="$(date +%s)"
  if [ -f "$cache" ]; then
    mtime="$(stat -c %Y "$cache" 2>/dev/null || printf 0)"
    if [ $((now - mtime)) -lt 1800 ]; then
      cat "$cache" 2>/dev/null || printf 0
      return 0
    fi
  fi

  count="0"
  if [ -x /usr/lib/update-notifier/apt-check ]; then
    raw="$(/usr/lib/update-notifier/apt-check 2>/dev/null || true)"
    count="${raw%%;*}"
  elif command -v apt >/dev/null 2>&1; then
    count="$(apt list --upgradable 2>/dev/null | awk 'NR>1 {n++} END {print n+0}')"
  fi

  printf '%s\n' "${count:-0}" > "$cache"
  printf '%s' "${count:-0}"
}

time_label="$(date '+%H:%M · %d-%m-%Y')"
count="$(update_count)"

printf '%%{A1:%s:}%s%%{A}' "$calendar_cmd" "$time_label"
if [ "${count:-0}" != "0" ]; then
  printf ' %%{F#7c5cff}%%{A1:%s:}↻%%{A}%%{F-}' "$updates_cmd"
fi
printf '\n'
