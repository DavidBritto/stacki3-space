#!/bin/bash
export DISPLAY="${DISPLAY:-:0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 1; done
setsid -f polybar example >> /tmp/polybar.log 2>&1
