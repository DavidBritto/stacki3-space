#!/usr/bin/env bash
set -euo pipefail

FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=80% --border=rounded --layout=reverse-list --info=inline}"

notify_bt() {
  dunstify -a bluetooth -t 2800 "Bluetooth" "$1" 2>/dev/null || true
}

bt_header() {
  local powered adapter connected_name
  powered="$(bt_powered)"
  adapter="$(bluetoothctl show 2>/dev/null | awk '/Controller /{print $2; exit}')"
  connected_name="$(bt_connected_name)"
  printf 'Adapter: %s | Power: %s' "${adapter:-none}" "${powered:-no}"
  if [ -n "$connected_name" ]; then
    printf ' | Conectado: %s' "$connected_name"
  fi
}

bt_powered() {
  bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}'
}

bt_connected_name() {
  local mac name
  while read -r _ mac _; do
    [ -n "${mac:-}" ] || continue
    if bluetoothctl info "$mac" 2>/dev/null | awk '/Connected:/{print $2; exit}' | grep -qx yes; then
      name="$(bluetoothctl info "$mac" 2>/dev/null | awk -F: '/Name:/{sub(/^ /,"",$2); print $2; exit}')"
      printf '%s' "${name:-$mac}"
      return 0
    fi
  done < <(bluetoothctl devices 2>/dev/null)
}

ensure_adapter() {
  rfkill unblock bluetooth 2>/dev/null || true
  if ! bluetoothctl show >/dev/null 2>&1; then
    notify_bt "No hay adaptador Bluetooth disponible"
    return 1
  fi
  bluetoothctl agent on >/dev/null 2>&1 || true
  bluetoothctl default-agent >/dev/null 2>&1 || true
  if [ "$(bt_powered)" != "yes" ]; then
    bluetoothctl power on >/dev/null 2>&1 || true
  fi
}

device_lines() {
  bluetoothctl devices 2>/dev/null | awk '{
    mac=$2
    name=$0
    sub(/^Device [^ ]+ /, "", name)
    printf "%s\t%s\n", mac, name
  }'
}

pick_device() {
  local prompt="$1"
  local line mac name
  line="$(device_lines | sort -t $'\t' -k2 | fzf --prompt="$prompt " --with-nth=2 --delimiter=$'\t' --header="$(bt_header)")" || return 1
  mac="${line%%$'\t'*}"
  name="${line#*$'\t'}"
  printf '%s\n%s' "$mac" "$name"
}

scan_devices() {
  printf '\nEscaneando dispositivos (12 s)...\n'
  bluetoothctl scan on >/dev/null 2>&1 || true
  sleep 12
  bluetoothctl scan off >/dev/null 2>&1 || true
  notify_bt "Escaneo finalizado"
}

action_scan_and_pair() {
  scan_devices
  mapfile -t picked < <(pick_device "Emparejar>" || true)
  [ "${#picked[@]}" -ge 2 ] || return 0
  local mac="${picked[0]}" name="${picked[1]}"
  bluetoothctl pair "$mac" >/dev/null 2>&1 || true
  bluetoothctl trust "$mac" >/dev/null 2>&1 || true
  if bluetoothctl connect "$mac" >/dev/null 2>&1; then
    notify_bt "Conectado: $name"
  else
    notify_bt "Emparejado: $name"
  fi
}

action_manage_paired() {
  mapfile -t picked < <(pick_device "Dispositivo>" || true)
  [ "${#picked[@]}" -ge 2 ] || return 0
  local mac="${picked[0]}" name="${picked[1]}"
  local choice
  choice="$(printf '%s\n' \
    'Conectar' \
    'Desconectar' \
    'Confiar' \
    'Eliminar emparejamiento' \
    'Volver' \
    | fzf --prompt="Acción · ${name}> " --header="$(bt_header)")" || return 0

  case "$choice" in
    Conectar)
      if bluetoothctl connect "$mac" >/dev/null 2>&1; then
        notify_bt "Conectado: $name"
      else
        notify_bt "No se pudo conectar: $name"
      fi
      ;;
    Desconectar)
      bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
      notify_bt "Desconectado: $name"
      ;;
    Confiar)
      bluetoothctl trust "$mac" >/dev/null 2>&1 || true
      notify_bt "Confiado: $name"
      ;;
    'Eliminar emparejamiento')
      bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
      bluetoothctl remove "$mac" >/dev/null 2>&1 || true
      notify_bt "Eliminado: $name"
      ;;
  esac
}

action_toggle_power() {
  if [ "$(bt_powered)" = "yes" ]; then
    bluetoothctl power off >/dev/null 2>&1 || true
    notify_bt "Bluetooth apagado"
  else
    bluetoothctl power on >/dev/null 2>&1 || true
    notify_bt "Bluetooth encendido"
  fi
}

if [ "${1:-}" = "toggle-power" ]; then
  ensure_adapter || exit 0
  action_toggle_power
  exit 0
fi

main_menu() {
  local choice
  while true; do
    choice="$(printf '%s\n' \
      'Buscar y emparejar' \
      'Dispositivos emparejados' \
      'Escanear sin emparejar' \
      'Encender / apagar adaptador' \
      'Salir' \
      | fzf --prompt='Bluetooth> ' --header="$(bt_header)")" || exit 0

    case "$choice" in
      'Buscar y emparejar') action_scan_and_pair ;;
      'Dispositivos emparejados') action_manage_paired ;;
      'Escanear sin emparejar') scan_devices ;;
      'Encender / apagar adaptador') action_toggle_power ;;
      Salir|"") exit 0 ;;
    esac
  done
}

command -v fzf >/dev/null 2>&1 || {
  printf 'fzf no está instalado\n'
  exit 1
}

ensure_adapter || exit 1
main_menu
