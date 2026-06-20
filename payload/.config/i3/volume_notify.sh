#!/usr/bin/env bash

set -euo pipefail

ACTION="${1:-}"
SINK="@DEFAULT_SINK@"
SOURCE="@DEFAULT_SOURCE@"
REPLACE_ID=991049

send_volume_notification() {
  local volume muted display_volume

  volume="$(pactl get-sink-volume "$SINK" | awk 'NR==1 {gsub(/%/, "", $5); print $5}')"
  muted="$(pactl get-sink-mute "$SINK" | awk '{print $2}')"

  if [ "$muted" = "yes" ]; then
    dunstify -a "volume" -u low -t 1200 -r "$REPLACE_ID" "muted"
    exit 0
  fi

  display_volume="$volume"
  if [ "$display_volume" -gt 100 ]; then
    display_volume=100
  fi

  dunstify \
    -a "volume" \
    -u low \
    -t 1200 \
    -r "$REPLACE_ID" \
    -h int:value:"$display_volume" \
    "" \
    "${display_volume}%"
}

send_mic_notification() {
  local muted

  muted="$(pactl get-source-mute "$SOURCE" | awk '{print $2}')"

  if [ "$muted" = "yes" ]; then
    dunstify -a "volume" -u low -t 1200 -r "$REPLACE_ID" "Microphone muted"
  else
    dunstify -a "volume" -u low -t 1200 -r "$REPLACE_ID" "Microphone enabled"
  fi
}

case "$ACTION" in
  up)
    pactl set-sink-volume "$SINK" +10%
    send_volume_notification
    ;;
  down)
    pactl set-sink-volume "$SINK" -10%
    send_volume_notification
    ;;
  mute)
    pactl set-sink-mute "$SINK" toggle
    send_volume_notification
    ;;
  mic)
    pactl set-source-mute "$SOURCE" toggle
    send_mic_notification
    ;;
  *)
    echo "Usage: $0 {up|down|mute|mic}" >&2
    exit 1
    ;;
esac
