#!/usr/bin/env bash
set -euo pipefail

APPLY=false
if [ "${1:-}" = "--apply" ]; then
  APPLY=true
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<'EOF'
Install STACKI3-Space base dependencies.

Usage:
  scripts/install-dependencies.sh          # print the install plan
  scripts/install-dependencies.sh --apply  # install with apt-get

This script targets Linux Mint / Ubuntu / Debian-like systems.
EOF
  exit 0
elif [ -n "${1:-}" ]; then
  echo "[stacki3-space-deps] unknown argument: $1" >&2
  exit 2
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "[stacki3-space-deps] apt-get not found; this dependency set targets Linux Mint/Debian systems." >&2
  exit 1
fi

APT_PACKAGES=(
  i3-wm
  picom
  polybar
  rofi
  dunst
  lightdm
  slick-greeter
  xss-lock
  i3lock
  feh
  dex
  flameshot
  network-manager
  bluez
  gnome-terminal
  nemo
  zathura
  kitty
  tmux
  zsh
  fzf
  zoxide
  ripgrep
  fd-find
  eza
  git
  rsync
  xsel
  xdotool
  htop
  python3-gi
  ffmpeg
  poppler-utils
  p7zip-full
  chafa
  alsa-utils
  imagemagick
  curl
  netcat-openbsd
  qutebrowser
  playerctl
  xclip
)

echo "[stacki3-space-deps] apt packages:"
printf '  %s\n' "${APT_PACKAGES[@]}"

cat <<'EOF'

[stacki3-space-deps] external tools still managed outside apt:
  - oh-my-posh
  - atuin
  - yazi
  - lazygit
  - lazyjournal
  - greenclip
  - brave-origin-nightly or brave-browser
  - resvg, optional for fuller Yazi SVG previews

Install lazyjournal with:
  scripts/install-lazyjournal.sh

EOF

if [ "$APPLY" != true ]; then
  echo "[stacki3-space-deps] dry run only. No packages were installed."
  echo "[stacki3-space-deps] Re-run with --apply to install apt packages."
  exit 0
fi

echo "[stacki3-space-deps] installing apt packages"
sudo apt-get update
sudo apt-get install -y "${APT_PACKAGES[@]}"

echo "[stacki3-space-deps] done"
