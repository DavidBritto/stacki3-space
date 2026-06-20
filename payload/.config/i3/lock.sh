#!/usr/bin/env bash
set -euo pipefail

bg="#000000"
surface="#050711"
elevated="#0b1020"
accent="#4961da"
cyan="#67c9e4"
text="#b8cdfe"
text_dim="#444b6f"

wallpaper="${HOME}/Imágenes/wallpapers/wallpaper.jpg"
cache_dir="${HOME}/.cache/i3lock"
output="${cache_dir}/space-ops-lock.png"
font="${HOME}/.local/share/fonts/IBMPlexMono-Regular.ttf"

mkdir -p "${cache_dir}"

resolution="$(xrandr --current 2>/dev/null | awk '/\*/ { print $1; exit }' || true)"
if [[ -z "${resolution}" ]]; then
  resolution="$(xdpyinfo 2>/dev/null | awk '/dimensions:/ { print $2; exit }' || true)"
fi
resolution="${resolution:-1920x1080}"

width="${resolution%x*}"
height="${resolution#*x}"

screen_from_xrandr="$(xrandr 2>/dev/null | awk '/ current / { print $8 "x" $10; exit }' | tr -d ',' || true)"
if [[ -n "${screen_from_xrandr}" ]]; then
  resolution="${screen_from_xrandr}"
fi

if [[ -f "${wallpaper}" ]]; then
  convert "${wallpaper}" \
    -resize "${resolution}^" \
    -gravity center \
    -extent "${resolution}" \
    -blur 0x6 \
    \( -size "${resolution}" "xc:${bg}" -alpha set -channel A -evaluate set 48% \) \
    -compose over -composite \
    "${output}"
else
  convert -size "${resolution}" "xc:${bg}" \
    "${output}"
fi

if [[ "${1:-}" == "--render-only" ]]; then
  printf '%s\n' "${output}"
  exit 0
fi

exec i3lock \
  --nofork \
  --ignore-empty-password \
  --show-failed-attempts \
  --no-unlock-indicator \
  --image="${output}"
