#!/usr/bin/env bash
set -euo pipefail

REPO_REF="${STACKI3_SPACE_REPO_REF:-main}"
if [ -n "${STACKI3_SPACE_REPO_URL:-}" ]; then
  REPO_URL="$STACKI3_SPACE_REPO_URL"
elif [ -n "${STACKI3_SPACE_REPO_OWNER:-}" ] && [ -n "${STACKI3_SPACE_REPO_NAME:-}" ]; then
  REPO_URL="https://github.com/${STACKI3_SPACE_REPO_OWNER}/${STACKI3_SPACE_REPO_NAME}.git"
else
  REPO_URL=""
fi
TARGET_HOME="${HOME}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/stacki3-space"
BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR=""
INSTALL_DEPS="${STACKI3_SPACE_INSTALL_DEPS:-0}"

usage() {
  cat <<EOF
STACKI3-Space installer

Usage:
  bash install.sh [--deps] [--help]

Options:
  --deps, --install-deps, --full
                      Install Linux Mint/Debian APT dependencies before
                      deploying the STACKI3-Space config payload.

Environment:
  STACKI3_SPACE_REPO_URL    Git remote to clone when payload/ is not bundled
                      with install.sh. Required for remote-only installs.
  STACKI3_SPACE_REPO_OWNER  Optional GitHub owner; used with STACKI3_SPACE_REPO_NAME
                      when STACKI3_SPACE_REPO_URL is unset.
  STACKI3_SPACE_REPO_NAME   Optional GitHub repository name.
  STACKI3_SPACE_REPO_REF    Branch, tag, or ref to clone. Default: main
  STACKI3_SPACE_OVERWRITE_ZSHRC
                      Set to 1 to replace an existing ~/.zshrc.
                      Default: keep existing ~/.zshrc and only add safe aliases.
  STACKI3_SPACE_INSTALL_DEPS
                      Set to 1 to install APT dependencies before deployment.

Examples:
  bash install.sh
  bash install.sh --deps
  STACKI3_SPACE_REPO_URL=<your-repo-url> bash install.sh
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
      echo "[stacki3-space] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[stacki3-space] missing dependency: $1" >&2
    exit 1
  }
}

log() {
  printf '[stacki3-space] %s\n' "$*"
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
  if [ -z "$REPO_URL" ]; then
    echo "[stacki3-space] payload/ not found next to install.sh and no git remote configured" >&2
    echo "[stacki3-space] run from this repo checkout, set STACKI3_SPACE_REPO_URL, or use scripts/package.sh" >&2
    exit 1
  fi
  WORK_DIR="$(mktemp -d)"
  log "cloning $REPO_URL#$REPO_REF"
  git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$WORK_DIR/repo"
  SRC_ROOT="$WORK_DIR/repo"
fi

PAYLOAD="$SRC_ROOT/payload"
[ -d "$PAYLOAD" ] || { echo "[stacki3-space] payload not found" >&2; exit 1; }

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
if [ "${STACKI3_SPACE_OVERWRITE_ZSHRC:-0}" = "1" ] || [ ! -e "$TARGET_HOME/.zshrc" ]; then
  rsync -a "$PAYLOAD/" "$TARGET_HOME/"
else
  rsync -a --exclude='.zshrc' "$PAYLOAD/" "$TARGET_HOME/"
fi

replace_home_placeholders() {
  local escaped_home
  escaped_home="$(printf '%s' "$TARGET_HOME" | sed 's#[/&]#\\&#g')"

  while IFS= read -r file; do
    if grep -Iq . "$file" && grep -q "__STACKI3_SPACE_HOME__" "$file"; then
      sed -i "s#__STACKI3_SPACE_HOME__#$escaped_home#g" "$file"
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
