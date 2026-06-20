#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
def fail():
    print("")
    raise SystemExit(0)

try:
    from gi.repository import Gio, GLib
except Exception:
    fail()

BUS = "org.mpris.MediaPlayer2.spotify"
PATH = "/org/mpris/MediaPlayer2"
PLAYER = "org.mpris.MediaPlayer2.Player"
PROPS = "org.freedesktop.DBus.Properties"

def unpack_value(value):
    return value.unpack() if hasattr(value, "unpack") else value

def get_property(proxy, name):
    result = proxy.call_sync(
        "Get", GLib.Variant("(ss)", (PLAYER, name)), Gio.DBusCallFlags.NONE, 700, None
    )
    outer = unpack_value(result)
    value = outer[0] if isinstance(outer, tuple) else outer
    return unpack_value(value)

try:
    proxy = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION, Gio.DBusProxyFlags.NONE, None, BUS, PATH, PROPS, None
    )
    status = str(get_property(proxy, "PlaybackStatus") or "")
    metadata = get_property(proxy, "Metadata") or {}
    title = str(metadata.get("xesam:title", "")).strip()
    artists = metadata.get("xesam:artist", [])
    artist = str(artists[0]).strip() if artists else ""
except Exception:
    fail()

text = " · ".join(part for part in [title, artist] if part)
if not text:
    fail()

status_prefix = "Ⅱ " if status == "Paused" else "♪ "
limit = 24
if len(text) > limit:
    text = text[: limit - 3].rstrip() + "..."
print(f"{status_prefix}{text}")
PY
