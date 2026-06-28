#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# network_tui.sh — WiFi manager friendly con fzf + nmcli
# Misma onda que bluetooth_tui.sh pero para redes inalámbricas.
# ─────────────────────────────────────────────────────────────
set -euo pipefail

FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=80% --border=rounded --layout=reverse-list --info=inline}"

notify_net() {
  dunstify -a network -t 2800 "WiFi" "$1" 2>/dev/null || true
}

# ── helpers ─────────────────────────────────────────────────

wifi_enabled() {
  LC_ALL=C nmcli -t -f WIFI general 2>/dev/null | head -1
}

current_ssid() {
  LC_ALL=C nmcli -t -f ACTIVE,SSID device wifi list 2>/dev/null \
    | awk -F: '/^yes:/{print $2; exit}'
}

current_device() {
  LC_ALL=C nmcli -t -f DEVICE,TYPE device status 2>/dev/null \
    | awk -F: '/wifi$/{print $1; exit}'
}

current_ip() {
  local dev
  dev="$(current_device)"
  [ -n "$dev" ] || return 0
  LC_ALL=C nmcli -t -f IP4.ADDRESS device show "$dev" 2>/dev/null \
    | sed -n 's/^IP4\.ADDRESS\[1\]:\(.*\)\/.*/\1/p'
}

signal_icon() {
  local bars="$1"
  case "$bars" in
    ▂▄▆█) printf '████' ;;
    ▂▄▆_) printf '███_' ;;
    ▂▄__) printf '██__' ;;
    ▂___) printf '█___' ;;
    *)     printf '____' ;;
  esac
}

# ── header ──────────────────────────────────────────────────

net_header() {
  local ssid dev ip
  ssid="$(current_ssid)"
  dev="$(current_device)"
  ip="$(current_ip)"
  if [ -n "$ssid" ]; then
    printf 'Conectado: %s' "$ssid"
    [ -n "$ip" ] && printf ' | IP: %s' "$ip"
  else
    printf 'Sin conexión WiFi'
  fi
  printf ' | '
  if [ "$(wifi_enabled)" = "enabled" ]; then
    printf 'On'
  else
    printf 'Off'
  fi
}

# ── wifi list ────────────────────────────────────────────────

wifi_scan() {
  nmcli device wifi rescan >/dev/null 2>&1 || true
}

wifi_lines() {
  LC_ALL=C nmcli -t -f SSID,SIGNAL,SECURITY,BARS device wifi list 2>/dev/null \
    | while IFS=: read -r ssid signal security bars; do
      [ -n "$ssid" ] || continue
      local icon
      icon="$(signal_icon "$bars")"
      printf '%s\t%s\t%s\t%s\n' "$ssid" "$signal" "$security" "$icon"
    done
}

pick_network() {
  local prompt="$1"
  local header="$(net_header)  |  Ctrl-R: rescan"
  local line

  # Escaneo rápido silencioso al abrir
  wifi_scan &

  line="$(
    wifi_lines \
      | sort -t$'\t' -k2 -rn \
      | fzf \
        --prompt="$prompt " \
        --with-nth=1,2,4 \
        --delimiter=$'\t' \
        --header="$header" \
        --bind="ctrl-r:reload(sleep 1; wifi_lines | sort -t$'\t' -k2 -rn)" \
    )" || return

  [ -n "$line" ] || return
  printf '%s' "$line"
}

# ── connect ─────────────────────────────────────────────────

action_connect() {
  local line ssid signal security
  line="$(pick_network "Conectar>")" || return 0
  [ -n "$line" ] || return 0

  ssid="$(printf '%s' "$line" | awk -F'\t' '{print $1}')"
  signal="$(printf '%s' "$line" | awk -F'\t' '{print $2}')"
  security="$(printf '%s' "$line" | awk -F'\t' '{print $3}')"
  [ -n "$ssid" ] || return 0

  # Si ya estamos conectados a esa red, salir
  [ "$ssid" = "$(current_ssid)" ] && {
    notify_net "Ya estás conectado a $ssid"
    return 0
  }

  # Intentar conectar con perfil guardado
  local saved
  saved="$(LC_ALL=C nmcli -t -f NAME connection show 2>/dev/null | grep -Fx "$ssid" || true)"

  if [ -n "$saved" ]; then
    if nmcli connection up "$ssid" >/dev/null 2>&1; then
      notify_net "Conectado a $ssid"
      return 0
    fi
    # Perfil guardado falló — probablemente clave incorrecta, lo borramos
    nmcli connection delete "$ssid" >/dev/null 2>&1 || true
  fi

  # Pedir contraseña si tiene seguridad
  if [ -n "$security" ] && [ "$security" != "" ]; then
    local password
    clear 2>/dev/null || true
    printf '  ─────────────────────────────────\n'
    printf '  Red:     %s\n' "$ssid"
    printf '  Tipo:    %s\n' "$security"
    printf '  Señal:   %s%%\n' "$signal"
    printf '  ─────────────────────────────────\n\n'
    printf '  Contraseña (Enter vacío = cancelar): '
    IFS= read -rs password
    printf '\n'

    [ -z "$password" ] && {
      notify_net "Conexión cancelada"
      return 0
    }

    if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
      notify_net "Conectado a $ssid"
    else
      # nmcli crea perfil aunque falle — lo borramos para permitir reintento limpio
      nmcli connection delete "$ssid" >/dev/null 2>&1 || true
      notify_net "Contraseña incorrecta"
    fi
  else
    # Red abierta
    nmcli device wifi connect "$ssid" >/dev/null 2>&1 \
      && notify_net "Conectado a $ssid" \
      || notify_net "No se pudo conectar a $ssid"
  fi
}

# ── saved connections ───────────────────────────────────────

saved_connections() {
  LC_ALL=C nmcli -t -f NAME,TYPE connection show 2>/dev/null \
    | grep ':wifi$' \
    | sed 's/:wifi$//'
}

action_manage_saved() {
  local choice ssid
  while true; do
    choice="$(
      { saved_connections; printf 'Volver\n'; } \
        | fzf --prompt="Guardadas>" --header="$(net_header)" \
      )" || return 0
    [ "$choice" = "Volver" ] || [ -z "$choice" ] && return 0

    local action
    action="$(
      printf '%s\n' \
        'Conectar' \
        'Esquiciar contraseña' \
        'Olvidar esta red' \
        'Volver' \
        | fzf --prompt="$choice > " --header="$(net_header)"
    )" || continue

    case "$action" in
      Conectar)
        nmcli connection up "$choice" >/dev/null 2>&1 \
          && notify_net "Conectado a $choice" \
          || notify_net "No se pudo conectar a $choice"
        ;;
      'Esquiciar contraseña')
        local pass
        pass="$(LC_ALL=C nmcli -s -t -f 802-11-wireless-security.psk connection show "$choice" 2>/dev/null || true)"
        if [ -n "$pass" ]; then
          printf 'Contraseña de "%s":\n%s\n' "$choice" "$pass"
          printf '\nPresiona una tecla para volver...'
          IFS= read -rsn1 _
        else
          notify_net "No hay contraseña guardada o es red abierta"
        fi
        ;;
      'Olvidar esta red')
        nmcli connection delete "$choice" >/dev/null 2>&1 \
          && notify_net "Red olvidada: $choice" \
          || notify_net "No se pudo eliminar $choice"
        ;;
    esac
  done
}

# ── connection status ───────────────────────────────────────

action_status() {
  local ssid dev ip signal msg
  ssid="$(current_ssid)"
  dev="$(current_device)"
  ip="$(current_ip)"

  if [ -n "$ssid" ]; then
    signal="$(LC_ALL=C nmcli -t -f SIGNAL device wifi list 2>/dev/null \
      | awk -F: "/^$ssid:/{print \$2; exit}")"
    msg="Conectado a: $ssid"
    [ -n "$signal" ] && msg="$msg (señal: ${signal}%)"
    [ -n "$ip" ] && msg="$msg\nIP: $ip"
    [ -n "$dev" ] && msg="$msg\nInterfaz: $dev"
  else
    if [ "$(wifi_enabled)" = "enabled" ]; then
      msg="WiFi encendido, sin conexión"
    else
      msg="WiFi apagado"
    fi
  fi

  printf '%b\n' "$msg"
  printf '\nPresiona una tecla para volver...'
  IFS= read -rsn1 _
}

# ── toggle wifi ─────────────────────────────────────────────

action_toggle_wifi() {
  if [ "$(wifi_enabled)" = "enabled" ]; then
    nmcli radio wifi off >/dev/null 2>&1
    notify_net "WiFi apagado"
  else
    nmcli radio wifi on >/dev/null 2>&1
    notify_net "WiFi encendido"
  fi
}

# ── hotspot ─────────────────────────────────────────────────

action_hotspot() {
  local dev
  dev="$(current_device)"
  [ -z "$dev" ] && { notify_net "No hay interfaz WiFi"; return 0; }

  local current
  current="$(LC_ALL=C nmcli connection show --active 2>/dev/null \
    | grep ':hotspot' || true)"

  if [ -n "$current" ]; then
    nmcli connection down Hotspot >/dev/null 2>&1 || true
    notify_net "Hotspot desactivado"
  else
    nmcli device wifi hotspot ifname "$dev" ssid "STACK-$(hostname -s)" \
      password "$(hostname | md5sum | head -c 8)" >/dev/null 2>&1 \
      && notify_net "Hotspot activado • SSID: STACK-$(hostname -s)" \
      || notify_net "No se pudo crear hotspot"
  fi
}

# ── support: password prompt for manual connect ────────────

action_connect_manual() {
  local ssid password
  clear 2>/dev/null || true
  printf '\n  ─────────────────────────────────\n'
  printf '  Conectar a red oculta\n'
  printf '  ─────────────────────────────────\n\n'
  printf '  Nombre de red (SSID): '
  IFS= read -r ssid
  [ -z "$ssid" ] && return 0

  printf '  Contraseña (vacío si es abierta): '
  IFS= read -rs password
  printf '\n'

  if [ -n "$password" ]; then
    if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
      notify_net "Conectado a $ssid"
    else
      nmcli connection delete "$ssid" >/dev/null 2>&1 || true
      notify_net "No se pudo conectar"
    fi
  else
    if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
      notify_net "Conectado a $ssid"
    else
      nmcli connection delete "$ssid" >/dev/null 2>&1 || true
      notify_net "No se pudo conectar (¿requiere contraseña?)"
    fi
  fi
}

# ── main menu ───────────────────────────────────────────────

main_menu() {
  local choice
  while true; do
    choice="$(
      printf '%s\n' \
        ' Conectar a red WiFi' \
        ' Redes guardadas' \
        ' Estado de conexión' \
        ' Encender / apagar WiFi' \
        ' Hotspot' \
        ' Conectar red oculta (SSID manual)' \
        ' nmtui (avanzado)' \
        ' Salir' \
        | fzf --prompt='WiFi> ' --header="$(net_header)"
    )" || exit 0

    case "$choice" in
      ' Conectar a red WiFi')     action_connect ;;
      ' Redes guardadas')         action_manage_saved ;;
      ' Estado de conexión')      action_status ;;
      ' Encender / apagar WiFi')  action_toggle_wifi ;;
      ' Hotspot')                 action_hotspot ;;
      ' Conectar red oculta'*)    action_connect_manual ;;
      ' nmtui (avanzado)')       exec nmtui ;;
      Salir|"")                     exit 0 ;;
    esac
  done
}

# ── entry ───────────────────────────────────────────────────

command -v fzf >/dev/null 2>&1 || {
  printf 'fzf no está instalado\n'
  exit 1
}

case "${1:-}" in
  toggle-wifi) action_toggle_wifi ;;
  *)           main_menu ;;
esac
