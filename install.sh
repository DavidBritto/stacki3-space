#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${STACKI3_REPO_OWNER:-Gentleman-Programming}"
REPO_NAME="${STACKI3_REPO_NAME:-stacki3}"
REPO_URL="${STACKI3_REPO_URL:-https://github.com/${REPO_OWNER}/${REPO_NAME}.git}"
REPO_REF="${STACKI3_REPO_REF:-main}"
TARGET_HOME="${HOME}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/stacki3"
BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=""
INSTALL_DEPS="${STACKI3_INSTALL_DEPS:-0}"

usage() {
  cat <<EOF
STACKI3 installer

Usage:
  bash install.sh [--deps] [--help]

Options:
  --deps, --install-deps, --full
                      Install Linux Mint/Debian APT dependencies before
                      deploying the STACKI3 config payload.

Environment:
  STACKI3_REPO_OWNER  GitHub owner used by curl/bootstrap installs.
                      Default: Gentleman-Programming
  STACKI3_REPO_NAME   GitHub repository name. Default: stacki3
  STACKI3_REPO_URL    Full git URL. Overrides owner/name.
  STACKI3_REPO_REF    Branch, tag, or ref to clone. Default: main
  STACKI3_OVERWRITE_ZSHRC
                      Set to 1 to replace an existing ~/.zshrc.
                      Default: keep existing ~/.zshrc and only add safe aliases.
  STACKI3_INSTALL_DEPS
                      Set to 1 to install APT dependencies before deployment.

Examples:
  bash install.sh
  bash install.sh --deps
  STACKI3_REPO_URL=https://github.com/me/stacki3.git bash install.sh
  curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/stacki3/main/install.sh | bash -s -- --deps
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --deps|--install-deps|--full)
      INSTALL_DEPS=1
      ;;
    *)
      echo "[stacki3] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[stacki3] missing dependency: $1" >&2
    exit 1
  }
}

log() {
  printf '[stacki3] %s\n' "$*"
}

cleanup() {
  [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ] && rm -rf "$WORK_DIR"
  return 0
}
trap cleanup EXIT

need git
need rsync
need install

if [ -d "$SCRIPT_DIR/payload" ]; then
  SRC_ROOT="$SCRIPT_DIR"
else
  WORK_DIR="$(mktemp -d)"
  log "cloning $REPO_URL#$REPO_REF"
  git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$WORK_DIR/repo" >/dev/null 2>&1
  SRC_ROOT="$WORK_DIR/repo"
fi

PAYLOAD="$SRC_ROOT/payload"
[ -d "$PAYLOAD" ] || { echo "[stacki3] payload not found" >&2; exit 1; }

if [ "$INSTALL_DEPS" = "1" ]; then
  log "installing APT dependencies"
  bash "$SRC_ROOT/scripts/install-dependencies.sh" --apply
else
  log "dependency install skipped; run scripts/install-dependencies.sh --apply or rerun this installer with --deps"
fi

mkdir -p "$BACKUP_DIR" "$TARGET_HOME/.config" "$TARGET_HOME/.local/bin"

backup_if_exists() {
  local rel="$1"
  local src="$TARGET_HOME/$rel"
  local dst="$BACKUP_DIR/$rel"
  if [ -e "$src" ] || [ -L "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
  fi
}

log "creating backups in $BACKUP_DIR"
while IFS= read -r rel; do
  backup_if_exists "$rel"
done < <(cd "$PAYLOAD" && find . -mindepth 1 ! -type d | sed 's#^\./##' | sort)

log "syncing payload to $TARGET_HOME"
if [ "${STACKI3_OVERWRITE_ZSHRC:-0}" = "1" ] || [ ! -e "$TARGET_HOME/.zshrc" ]; then
  rsync -a "$PAYLOAD/" "$TARGET_HOME/"
else
  rsync -a --exclude='.zshrc' "$PAYLOAD/" "$TARGET_HOME/"
fi

replace_home_placeholders() {
  local escaped_home
  escaped_home="$(printf '%s' "$TARGET_HOME" | sed 's#[/&]#\\&#g')"

  while IFS= read -r file; do
    if grep -Iq . "$file" && grep -q "__STACKI3_HOME__" "$file"; then
      sed -i "s#__STACKI3_HOME__#$escaped_home#g" "$file"
    fi
  done < <(
    find "$TARGET_HOME/.config" "$TARGET_HOME/.local/bin" -type f 2>/dev/null
    [ -f "$TARGET_HOME/.zshrc" ] && printf '%s\n' "$TARGET_HOME/.zshrc"
    [ -f "$TARGET_HOME/.tmux.conf" ] && printf '%s\n' "$TARGET_HOME/.tmux.conf"
  )
}

replace_home_placeholders

ensure_zsh_line() {
  local line="$1"
  local marker="${2:-}"
  local zshrc="$TARGET_HOME/.zshrc"

  [ -f "$zshrc" ] || return 0
  grep -Fqx "$line" "$zshrc" && return 0

  if [ -n "$marker" ] && grep -Fqx "$marker" "$zshrc"; then
    local tmp
    tmp="$(mktemp)"
    awk -v marker="$marker" -v line="$line" '
      { print }
      $0 == marker && !done { print line; done = 1 }
    ' "$zshrc" > "$tmp"
    install -m 0644 "$tmp" "$zshrc"
    rm -f "$tmp"
  else
    printf '\n%s\n' "$line" >> "$zshrc"
  fi
}

ensure_zsh_line \
  "command -v lazyjournal &>/dev/null && alias lj='lazyjournal'" \
  "command -v lazygit    &>/dev/null && alias lg='lazygit'"

chmod +x \
  "$TARGET_HOME/.local/bin/deskmenu" \
  "$TARGET_HOME/.local/bin/tui-panel" \
  "$TARGET_HOME/.local/bin/shortcuts-help" \
  "$TARGET_HOME/.local/bin/polkit-agent-oceano" \
  "$TARGET_HOME/.local/bin/apply-slick-greeter-oceano" \
  "$TARGET_HOME/.local/bin/fd" \
  "$TARGET_HOME/.local/bin/tmux-copy" \
  "$TARGET_HOME/.local/bin/tmux-net-health" \
  "$TARGET_HOME/.local/bin/tmux-net-debug" \
  "$TARGET_HOME/.local/bin/try" \
  "$TARGET_HOME/.local/bin/space" \
  "$TARGET_HOME/.local/bin/stack-theme" \
  "$TARGET_HOME/.config/i3/volume_notify.sh" \
  "$TARGET_HOME/.config/i3/power_menu.sh" \
  "$TARGET_HOME/.config/i3/power_auth_terminal.sh" \
  "$TARGET_HOME/.config/i3/power_notify.sh" \
  "$TARGET_HOME/.config/i3/lock.sh" \
  "$TARGET_HOME/.config/polybar/launch.sh" \
  "$TARGET_HOME/.config/polybar/scripts/ram_status.sh" \
  "$TARGET_HOME/.config/polybar/scripts/cpu_status.sh" \
  "$TARGET_HOME/.config/polybar/scripts/music_status.sh" \
  "$TARGET_HOME/.config/polybar/scripts/updates_status.sh" \
  "$TARGET_HOME/.config/polybar/scripts/volume_status.sh" \
  "$TARGET_HOME/.config/polybar/scripts/spotify_tui.py"

log "done"
log "next steps: reload i3, restart polybar/dunst if needed, then test mod+p / mod+o / mod+F1"
