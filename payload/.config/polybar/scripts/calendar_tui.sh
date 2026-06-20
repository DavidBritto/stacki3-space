#!/usr/bin/env bash
set -euo pipefail

if ! command -v kitty >/dev/null 2>&1; then
  exit 0
fi


calendar_exists() {
  i3-msg -t get_tree | python3 -c '
import json
import sys
root = json.load(sys.stdin)
stack = [root]
while stack:
    node = stack.pop()
    if node.get("name") == "Space Calendar":
        raise SystemExit(0)
    stack.extend(node.get("nodes", []))
    stack.extend(node.get("floating_nodes", []))
raise SystemExit(1)
'
}

position_calendar_popover() {
  local reveal="${1:-no}"
  local polybar_gap=12
  local i3_action
  local coords x y

  for _ in {1..20}; do
    coords="$(
      python3 - "$polybar_gap" <<'PY_POS' || true
import json
import subprocess
import sys

gap = int(sys.argv[1])

def load_i3(kind):
    return json.loads(subprocess.check_output(['i3-msg', '-t', kind], text=True))

def find_window(node):
    if node.get('name') == 'Space Calendar':
        return node
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        found = find_window(child)
        if found:
            return found
    return None

tree = load_i3('get_tree')
workspaces = load_i3('get_workspaces')
window = find_window(tree)
focused = next((ws for ws in workspaces if ws.get('focused')), None)
if not window or not focused:
    raise SystemExit(0)

win = window.get('rect') or {}
screen = focused.get('rect') or {}
width = int(win.get('width') or 226)
height = int(win.get('height') or 210)
sx = int(screen.get('x') or 0)
sy = int(screen.get('y') or 0)
sw = int(screen.get('width') or 1920)

# Polybar is top-aligned. Place the popover below it, horizontally centered.
# Clamp y so the panel never starts above the visible workspace area.
x = sx + max(0, (sw - width) // 2)
y = sy + gap
print(x, y)
PY_POS
    )"
    if [ -n "$coords" ]; then
      IFS=' ' read -r x y <<EOF
$coords
EOF
    [ -n "${x:-}" ] && [ -n "${y:-}" ] || continue
      i3_action="floating enable, move position ${x} ${y}, focus"
      if [ "$reveal" = "reveal" ]; then
        i3_action="scratchpad show, ${i3_action}"
      fi
      i3-msg "[title=\"Space Calendar\"] ${i3_action}" >/dev/null 2>&1 || true
      return 0
    fi
    sleep 0.1
  done
}

if calendar_exists; then
  position_calendar_popover
  exit 0
fi

kitty --detach \
  --class stack-calendar-panel \
  --title "Space Calendar" \
  --override scrollback_lines=0 \
  --override window_padding_width=14 \
  --override background=#000000 \
  --override foreground=#d7e0ff \
  --override cursor=#67c9e4 \
  --override cursor_text_color=#000000 \
  --override selection_background=#4961da \
  --override selection_foreground=#ffffff \
  --override active_window_border_color=#7c5cff \
  --override inactive_window_border_color=#7c5cff \
  --override color0=#000000 \
  --override color1=#7c5cff \
  --override color2=#67c9e4 \
  --override color3=#f0c674 \
  --override color4=#4961da \
  --override color5=#7c5cff \
  --override color6=#67c9e4 \
  --override color7=#d7e0ff \
  --override color8=#444b6f \
  --override color9=#9d7cff \
  --override color10=#8be9fd \
  --override color11=#f0c674 \
  --override color12=#5b72ff \
  --override color13=#9d7cff \
  --override color14=#67c9e4 \
  --override color15=#ffffff \
  --override remember_window_size=no \
  --override initial_window_width=24c \
  --override initial_window_height=10c \
  --working-directory "$HOME" \
  bash --noprofile --norc -c '
    export STACK_NO_AUTO_TMUX=1
    printf "\033]10;#d7e0ff\007\033]11;#000000\007\033]12;#67c9e4\007"
    clear

    wait_close() {
      printf "\033[0m\nPress q to close..."
      while IFS= read -rsn1 key; do
        [ "$key" = "q" ] && break
      done
    }

    if [ -f "$HOME/.config/khal/config" ] && command -v ikhal >/dev/null 2>&1; then
      exec ikhal
    elif [ -f "$HOME/.config/khal/config" ] && command -v khal >/dev/null 2>&1; then
      printf "\033[38;2;215;224;255m"
      khal calendar
      wait_close
    elif command -v ncal >/dev/null 2>&1; then
      printf "\033[38;2;215;224;255m"
      ncal -Mb
      wait_close
    elif command -v cal >/dev/null 2>&1; then
      printf "\033[38;2;215;224;255m"
      cal
      wait_close
    elif command -v python3 >/dev/null 2>&1; then
      printf "\033[38;2;215;224;255m"
      python3 - <<'"'"'PY_CAL'"'"'
import calendar
from datetime import date

today = date.today()
print(calendar.month(today.year, today.month))
PY_CAL
      wait_close
    else
      printf "\033[38;2;215;224;255mNo calendar TUI found.\033[0m\n"
      sleep 3
    fi
  ' &

position_calendar_popover reveal
