#!/usr/bin/env bash
set -euo pipefail

mark="__flameshot_return__"

# Guardar el foco actual para restaurarlo cuando Flameshot cierre su overlay.
i3-msg "mark --add ${mark}" >/dev/null

cleanup() {
  i3-msg "[con_mark=\"${mark}\"] unmark ${mark}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

flameshot gui "$@"

# Recuperar foco; esto evita que Picom deje todas las ventanas como inactivas.
i3-msg "[con_mark=\"${mark}\"] focus, unmark ${mark}" >/dev/null 2>&1 || true
