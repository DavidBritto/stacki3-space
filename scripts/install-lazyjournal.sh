#!/usr/bin/env bash
set -euo pipefail

INSTALL_URL="https://raw.githubusercontent.com/Lifailon/lazyjournal/main/scripts/install.sh"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<'EOF'
Install or update lazyjournal.

Usage:
  scripts/install-lazyjournal.sh

Installs the upstream lazyjournal binary to ~/.local/bin/lazyjournal and
its config to ~/.config/lazyjournal/config.yml.
EOF
  exit 0
elif [ -n "${1:-}" ]; then
  echo "[lazyjournal] unknown argument: $1" >&2
  exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "[lazyjournal] curl is required" >&2
  exit 1
fi

echo "[lazyjournal] installing from upstream"
curl -sSL "$INSTALL_URL" | bash

if command -v lazyjournal >/dev/null 2>&1; then
  lazyjournal --version 2>/dev/null || true
  echo "[lazyjournal] ready"
elif [ -x "$HOME/.local/bin/lazyjournal" ]; then
  "$HOME/.local/bin/lazyjournal" --version 2>/dev/null || true
  echo "[lazyjournal] ready: $HOME/.local/bin/lazyjournal"
else
  echo "[lazyjournal] install finished but lazyjournal was not found" >&2
  exit 1
fi
