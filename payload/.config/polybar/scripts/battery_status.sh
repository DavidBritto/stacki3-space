#!/usr/bin/env bash
set -euo pipefail

colors_file="$HOME/.config/polybar/colors-generated.ini"
accent="#7c5cff"
alert="#ff5f87"

if [ -f "$colors_file" ]; then
  accent="$(awk -F'= ' '/^primary = /{print $2}' "$colors_file" | head -n1)"
  alert="$(awk -F'= ' '/^alert = /{print $2}' "$colors_file" | head -n1)"
  [ -n "$accent" ] || accent="#7c5cff"
  [ -n "$alert" ] || alert="#ff5f87"
fi

battery_path=""
for supply in /sys/class/power_supply/*; do
  if [ "$(cat "$supply/type" 2>/dev/null || true)" = "Battery" ]; then
    battery_path="$supply"
    break
  fi
done

if [ -z "$battery_path" ]; then
  exit 0
fi

capacity="$(cat "$battery_path/capacity" 2>/dev/null || printf 0)"
status="$(cat "$battery_path/status" 2>/dev/null || printf Unknown)"

if ! [[ "${capacity:-}" =~ ^[0-9]+$ ]]; then
  exit 0
fi

if [ "$capacity" -gt 100 ]; then
  capacity=100
fi

discharge_icon() {
  if [ "$capacity" -le 10 ]; then
    printf '%s' $'󰁻'
  elif [ "$capacity" -le 20 ]; then
    printf '%s' $'󰁼'
  elif [ "$capacity" -le 30 ]; then
    printf '%s' $'󰁽'
  elif [ "$capacity" -le 40 ]; then
    printf '%s' $'󰁾'
  elif [ "$capacity" -le 50 ]; then
    printf '%s' $'󰁿'
  elif [ "$capacity" -le 60 ]; then
    printf '%s' $'󰂀'
  elif [ "$capacity" -le 70 ]; then
    printf '%s' $'󰂁'
  elif [ "$capacity" -le 80 ]; then
    printf '%s' $'󰂂'
  elif [ "$capacity" -le 90 ]; then
    printf '%s' $'󰂃'
  else
    printf '%s' $'󰁺'
  fi
}

charge_icon() {
  if [ "$capacity" -ge 95 ]; then
    printf '%s' $'󰂆'
  elif [ "$capacity" -ge 75 ]; then
    printf '%s' $'󰂇'
  elif [ "$capacity" -ge 55 ]; then
    printf '%s' $'󰂈'
  elif [ "$capacity" -ge 35 ]; then
    printf '%s' $'󰂉'
  elif [ "$capacity" -ge 15 ]; then
    printf '%s' $'󰂊'
  else
    printf '%s' $'󰂅'
  fi
}

label="$(printf '%d%%' "$capacity")"

case "$status" in
  Charging|Full)
    printf '%%{F%s}%%{T2}%s%%{T-} %s%%{F-}' "$accent" "$(charge_icon)" "$label"
    ;;
  *)
    if [ "$capacity" -le 15 ]; then
      printf '%%{F%s}%%{T2}%s%%{T-} %s%%{F-}' "$alert" "$(discharge_icon)" "$label"
    else
      printf '%%{T2}%s%%{T-} %s' "$(discharge_icon)" "$label"
    fi
    ;;
esac
