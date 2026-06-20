#!/usr/bin/env bash
set -euo pipefail

ROFI_THEME_ARGS=(-theme-str 'window {width: 360px;} listview {lines: 6;}')

menu() {
  printf '%s\n' \
    '⏻ apagar' \
    '󰜉 reiniciar' \
    '󰤄 suspender' \
    '󰌾 bloquear' \
    '󰍃 cerrar sesión' \
    'cancelar' | \
    rofi -dmenu -i -p 'Power' "${ROFI_THEME_ARGS[@]}"
}

confirm() {
  local label="$1"
  printf '%s\n' "confirmar ${label}" 'volver' 'cancelar' | \
    rofi -dmenu -i -p 'Confirmar' "${ROFI_THEME_ARGS[@]}"
}

run_action() {
  local action="$1"
  if "$HOME/.config/i3/power_action.sh" "$action"; then
    exit 0
  fi

  if command -v dunstify >/dev/null 2>&1; then
    dunstify -a power -u critical -t 3500 'Power' "No pude ejecutar: ${action}"
  fi
  exit 1
}

choice="$(menu)"
[ -n "${choice:-}" ] || exit 0

case "$choice" in
  '⏻ apagar')
    [ "$(confirm 'apagado')" = 'confirmar apagado' ] && run_action poweroff
    ;;
  '󰜉 reiniciar')
    [ "$(confirm 'reinicio')" = 'confirmar reinicio' ] && run_action reboot
    ;;
  '󰤄 suspender')
    [ "$(confirm 'suspensión')" = 'confirmar suspensión' ] && run_action suspend
    ;;
  '󰌾 bloquear')
    run_action lock
    ;;
  '󰍃 cerrar sesión')
    [ "$(confirm 'salida de sesión')" = 'confirmar salida de sesión' ] && run_action logout
    ;;
  *)
    exit 0
    ;;
esac
