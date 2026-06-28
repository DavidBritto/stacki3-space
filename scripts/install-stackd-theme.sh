#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/extensions/stackd-theme"
NAME="davidops.stackd-theme"

install_for_editor() {
  local base="$1"
  local dest="$base/$NAME"
  [ -d "$base" ] || return 0
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -a "$SRC/." "$dest/"
  printf 'installed %s -> %s\n' "$NAME" "$dest"
}

install_for_editor "${CURSOR_EXTENSIONS_DIR:-$HOME/.cursor/extensions}"
install_for_editor "${KIRO_EXTENSIONS_DIR:-$HOME/.kiro/extensions}"
