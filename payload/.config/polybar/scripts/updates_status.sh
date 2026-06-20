#!/usr/bin/env bash
set -euo pipefail

cache="${XDG_CACHE_HOME:-$HOME/.cache}/stacki3-space/updates-count"
mkdir -p "$(dirname "$cache")"

now="$(date +%s)"
if [ -f "$cache" ]; then
  mtime="$(stat -c %Y "$cache" 2>/dev/null || printf 0)"
  if [ $((now - mtime)) -lt 1800 ]; then
    count="$(cat "$cache" 2>/dev/null || printf 0)"
    if [ "${count:-0}" = "0" ]; then
      printf '\n'
    else
      printf '| UPD %s\n' "${count:-0}"
    fi
    exit 0
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
if [ "${count:-0}" = "0" ]; then
  printf '\n'
else
  printf '| UPD %s\n' "${count:-0}"
fi
