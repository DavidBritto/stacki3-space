#!/usr/bin/env bash
set -euo pipefail

FONT='pango:Berkeley Mono 11'
MSG='STACKI3-Space · confirmar apagado'
ACTION="cinnamon-session-quit --power-off --no-prompt || systemctl poweroff || poweroff || shutdown -h now"

exec i3-nagbar \
  -t warning \
  -f "$FONT" \
  -m "$MSG" \
  -B 'apagar ahora' "$ACTION" \
  -B 'cancelar' 'true'
