#!/usr/bin/env bash
set -euo pipefail

colors_file="$HOME/.config/polybar/colors-generated.ini"
accent="#67c9e4"
primary="#7c5cff"
dim="#444b6f"

if [ -f "$colors_file" ]; then
  accent="$(awk -F'= ' '/^secondary = /{print $2}' "$colors_file" | head -n1)"
  primary="$(awk -F'= ' '/^primary = /{print $2}' "$colors_file" | head -n1)"
  dim="$(awk -F'= ' '/^dim = /{print $2}' "$colors_file" | head -n1)"
  [ -n "$accent" ] || accent="#67c9e4"
  [ -n "$primary" ] || primary="#7c5cff"
  [ -n "$dim" ] || dim="#444b6f"
fi

glyph_off=$'󰂲'
glyph_on=$'󰂯'
glyph_connected=$'󰂱'

if rfkill list bluetooth 2>/dev/null | awk '/Soft blocked: yes/{found=1} END{exit found?0:1}'; then
  printf '%%{F%s}%%{T2}%s%%{T-}%%{F-}\n' "$dim" "$glyph_off"
  exit 0
fi

if ! bluetoothctl show >/dev/null 2>&1; then
  printf '%%{F%s}%%{T2}%s%%{T-}%%{F-}\n' "$dim" "$glyph_off"
  exit 0
fi

powered="$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}')"
if [ "${powered:-no}" != "yes" ]; then
  printf '%%{F%s}%%{T2}%s%%{T-}%%{F-}\n' "$dim" "$glyph_off"
  exit 0
fi

connected=0
while read -r _ mac _; do
  [ -n "${mac:-}" ] || continue
  if bluetoothctl info "$mac" 2>/dev/null | awk '/Connected:/{print $2; exit}' | grep -qx yes; then
    connected=1
    break
  fi
done < <(bluetoothctl devices 2>/dev/null)

if [ "$connected" -eq 1 ]; then
  printf '%%{F%s}%%{T2}%s%%{T-}%%{F-}\n' "$primary" "$glyph_connected"
else
  printf '%%{F%s}%%{T2}%s%%{T-}%%{F-}\n' "$accent" "$glyph_on"
fi
