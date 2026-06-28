#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# wifi_status.sh — Módulo de estado WiFi para polybar
# Solo glifo + color: conectado, sin conexión, o apagado.
# ─────────────────────────────────────────────────────────────
set -euo pipefail

colors_file="$HOME/.config/polybar/colors-generated.ini"
accent="#89DDFF"
dim="#413C48"
if [ -f "$colors_file" ]; then
  accent="$(awk -F'= ' '/^secondary = /{print $2}' "$colors_file" | head -n1)"
  [ -n "$accent" ] || accent="#89DDFF"
fi

ssid="$(LC_ALL=C nmcli -t -f ACTIVE,SSID device wifi list 2>/dev/null | awk -F: '/^yes:/{print $2; exit}')"
signal="$(LC_ALL=C nmcli -t -f ACTIVE,SIGNAL device wifi list 2>/dev/null | awk -F: '/^yes:/{print $2; exit}')"
enabled="$(LC_ALL=C nmcli -t -f WIFI general 2>/dev/null | head -1)"

if [ -n "$ssid" ]; then
  if [ -n "$signal" ] && [ "$signal" -gt 60 ]; then
    printf '%%{F%s}%%{F-}\n' "$accent"
  elif [ -n "$signal" ] && [ "$signal" -gt 30 ]; then
    printf '%%{F%s}%%{F-}\n' '#C792EA'
  else
    printf '%%{F%s}%%{F-}\n' "$accent"
  fi
elif [ "$enabled" = "enabled" ]; then
  printf '%%{F%s}直%%{F-}\n' "$dim"
else
  printf '%%{F%s}󰖪%%{F-}\n' "$dim"
fi
