#!/usr/bin/env bash
set -euo pipefail

colors_file="$HOME/.config/polybar/colors-generated.ini"
accent="#67c9e4"
dim="#444b6f"
if [ -f "$colors_file" ]; then
  accent="$(awk -F'= ' '/^secondary = /{print $2}' "$colors_file" | head -n1)"
  [ -n "$accent" ] || accent="#67c9e4"
fi

physical_up="$({
  for dev in /sys/class/net/*; do
    name="${dev##*/}"
    case "$name" in
      lo|docker*|br-*|veth*|virbr*|tun*|wg* ) continue ;;
    esac
    state="$(cat "$dev/operstate" 2>/dev/null || printf down)"
    case "$name" in
      en*|eth*)
        [ "$state" = up ] && printf 'wired\n' && exit 0
        ;;
      wl*)
        [ "$state" = up ] && printf 'wifi\n' && exit 0
        ;;
    esac
  done
  printf 'down\n'
})"

case "$physical_up" in
  wired)
    printf '%%{F%s}LAN%%{F-}\n' "$accent"
    ;;
  wifi)
    printf '%%{F%s}NET%%{F-}\n' "$accent"
    ;;
  *)
    printf '%%{F%s}NET%%{F-}\n' "$dim"
    ;;
esac
