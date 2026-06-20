#!/usr/bin/env bash

set -euo pipefail

# Glifos del modulo de internet.
# Cambia estas 3 variables si quieres ajustar el lenguaje visual del estado de red.
# Referencia util de iconos: https://www.nerdfonts.com/
ICON_ON=""
ICON_LIMITED="直"
ICON_OFF="󰖪"

state="$(nmcli -t -f CONNECTIVITY general 2>/dev/null | sed -n '1p' || true)"

case "$state" in
  full)
    printf '%%{F#67c9e4}%s%%{F-}\n' "$ICON_ON"
    ;;
  limited|portal)
    printf '%%{F#4961da}%s%%{F-}\n' "$ICON_LIMITED"
    ;;
  *)
    printf '%%{F#444b6f}%s%%{F-}\n' "$ICON_OFF"
    ;;
esac
