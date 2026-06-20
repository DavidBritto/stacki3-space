#!/usr/bin/env bash

set -euo pipefail

sink="@DEFAULT_SINK@"
colors_file="$HOME/.config/polybar/colors-generated.ini"
accent="#7c5cff"
dim="#444b6f"
white="#ffffff"

if [ -f "$colors_file" ]; then
  accent="$(awk -F'= ' '/^primary = /{print $2}' "$colors_file" | head -n1)"
  dim="$(awk -F'= ' '/^dim = /{print $2}' "$colors_file" | head -n1)"
  white="$(awk -F'= ' '/^white = /{print $2}' "$colors_file" | head -n1)"
  [ -n "$accent" ] || accent="#7c5cff"
  [ -n "$dim" ] || dim="#444b6f"
  [ -n "$white" ] || white="#ffffff"
fi

volume="$(pactl get-sink-volume "$sink" 2>/dev/null | awk 'NR==1 {gsub(/%/, "", $5); print $5}' || true)"
muted="$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}' || true)"

display_volume="${volume:-0}"
if ! [[ "$display_volume" =~ ^[0-9]+$ ]]; then
  display_volume=0
fi
if [ "$display_volume" -gt 100 ]; then
  display_volume=100
fi

slots=8
pos=$(( display_volume * slots / 100 ))
if [ "$pos" -gt "$slots" ]; then
  pos=$slots
fi

left=""
right=""
for _ in $(seq 1 "$pos" 2>/dev/null); do left+="─"; done
for _ in $(seq 1 $((slots - pos)) 2>/dev/null); do right+="─"; done

if [ "${muted:-yes}" = "yes" ]; then
  printf 'VOL %%{F%s}%s%%{F%s}│%%{F%s}%s%%{F-}\n' "$dim" "$left" "$white" "$dim" "$right"
else
  printf 'VOL %%{F%s}%s%%{F%s}│%s%%{F-}\n' "$accent" "$left" "$white" "$right"
fi
