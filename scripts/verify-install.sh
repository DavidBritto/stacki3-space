#!/usr/bin/env bash
set -euo pipefail

failures=0

check_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    printf '[ok] command: %s\n' "$name"
  else
    printf '[missing] command: %s\n' "$name"
    failures=$((failures + 1))
  fi
}

check_path() {
  local path="$1"
  if [ -e "$HOME/$path" ] || [ -L "$HOME/$path" ]; then
    printf '[ok] path: ~/%s\n' "$path"
  else
    printf '[missing] path: ~/%s\n' "$path"
    failures=$((failures + 1))
  fi
}

echo '[stacki3-verify] commands'
for cmd in i3 polybar rofi dunst picom kitty tmux zsh fzf zoxide rg fdfind eza rsync xsel xdotool python3 lazyjournal; do
  check_cmd "$cmd"
done

echo
echo '[stacki3-verify] deployed files'
for path in \
  .config/i3/config \
  .config/polybar/config.ini \
  .config/polybar/launch.sh \
  .config/dunst/dunstrc \
  .config/picom/picom.conf \
  .config/rofi/config.rasi \
  .config/stack-theme/current.json \
  .local/bin/space \
  .local/bin/stack-theme \
  .local/bin/deskmenu \
  .tmux.conf \
  .zshrc; do
  check_path "$path"
done

echo
if command -v space >/dev/null 2>&1; then
  space doctor || failures=$((failures + 1))
elif [ -x "$HOME/.local/bin/space" ]; then
  "$HOME/.local/bin/space" doctor || failures=$((failures + 1))
else
  echo '[missing] space doctor could not run'
  failures=$((failures + 1))
fi

echo
if [ "$failures" -eq 0 ]; then
  echo '[stacki3-verify] ready'
else
  printf '[stacki3-verify] %s check(s) need attention\n' "$failures"
  exit 1
fi
