#!/usr/bin/env python3
"""Keep i3 workspace 9 labeled with the current Spotify track."""

from __future__ import annotations

import fcntl
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any

from gi.repository import Gio, GLib

BUS_NAME = 'org.mpris.MediaPlayer2.spotify'
OBJECT_PATH = '/org/mpris/MediaPlayer2'
PLAYER_IFACE = 'org.mpris.MediaPlayer2.Player'
PROPERTIES_IFACE = 'org.freedesktop.DBus.Properties'
WORKSPACE_NUMBER = 9
MUSIC_GLYPH = '♪'
FALLBACK_LABEL = f'9:spotify {MUSIC_GLYPH}'
LABEL_LIMIT = 48
LOCK_PATH = '/tmp/stacki3-space-spotify-workspace-name.lock'


def truncate(value: str, limit: int = LABEL_LIMIT) -> str:
    value = ' '.join(value.split())
    if len(value) <= limit:
        return value
    return value[: max(1, limit - 1)].rstrip() + '…'


def workspace_label(info: dict[str, Any], limit: int = LABEL_LIMIT) -> str:
    if not info.get('available', True):
        return FALLBACK_LABEL

    title = str(info.get('title') or '').strip()
    artist = str(info.get('artist') or '').strip()
    if title and artist:
        text = f'{title} · {artist}'
    else:
        text = title or artist or 'spotify'

    prefix = f'{WORKSPACE_NUMBER}: '
    suffix = f' {MUSIC_GLYPH}'
    text_limit = max(1, limit - len(prefix) - len(suffix))
    return f'{prefix}{truncate(text, text_limit)}{suffix}'


def quote_i3(value: str) -> str:
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'


def rename_command(label: str, current_name: str = str(WORKSPACE_NUMBER)) -> str:
    return f'rename workspace {quote_i3(current_name)} to {quote_i3(label)}'


def run_i3(command: str) -> bool:
    if not shutil_which('i3-msg'):
        return False
    result = subprocess.run(['i3-msg', command], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode == 0


def current_workspace_name() -> str:
    if not shutil_which('i3-msg'):
        return str(WORKSPACE_NUMBER)
    try:
        result = subprocess.run(['i3-msg', '-t', 'get_workspaces'], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        for workspace in json.loads(result.stdout):
            if workspace.get('num') == WORKSPACE_NUMBER:
                return str(workspace.get('name') or WORKSPACE_NUMBER)
    except Exception:
        pass
    return str(WORKSPACE_NUMBER)


def shutil_which(command: str) -> str | None:
    for directory in os.environ.get('PATH', '').split(os.pathsep):
        candidate = Path(directory) / command
        if candidate.exists() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None


def proxy(interface: str) -> Gio.DBusProxy | None:
    try:
        return Gio.DBusProxy.new_for_bus_sync(
            Gio.BusType.SESSION,
            Gio.DBusProxyFlags.NONE,
            None,
            BUS_NAME,
            OBJECT_PATH,
            interface,
            None,
        )
    except GLib.Error:
        return None


def get_property(name: str) -> Any:
    p = proxy(PROPERTIES_IFACE)
    if p is None:
        return None
    try:
        result = p.call_sync(
            'Get',
            GLib.Variant('(ss)', (PLAYER_IFACE, name)),
            Gio.DBusCallFlags.NONE,
            1000,
            None,
        )
    except GLib.Error:
        return None
    value = result.unpack()[0]
    return value.unpack() if isinstance(value, GLib.Variant) else value


def spotify_info() -> dict[str, Any]:
    if proxy(PLAYER_IFACE) is None:
        return {'available': False}

    metadata = get_property('Metadata') or {}
    title = metadata.get('xesam:title', '')
    artists = metadata.get('xesam:artist', [])
    artist = ', '.join(artists) if isinstance(artists, (list, tuple)) else str(artists)
    return {'available': True, 'title': str(title), 'artist': artist}


class WorkspaceUpdater:
    def __init__(self) -> None:
        self.last_label = ''

    def update(self) -> None:
        label = workspace_label(spotify_info())
        if label == self.last_label:
            return
        if run_i3(rename_command(label, current_workspace_name())):
            self.last_label = label


def acquire_lock() -> object:
    lock = open(LOCK_PATH, 'w')
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        raise SystemExit(0)
    return lock


def main() -> int:
    acquire_lock()
    updater = WorkspaceUpdater()
    updater.update()

    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)

    def refresh(*_args: object) -> bool:
        updater.update()
        return False

    def on_properties_changed(*_args: object) -> None:
        GLib.idle_add(refresh)

    def on_name_owner_changed(_conn: object, _sender: str, _path: str, _iface: str, _signal: str, params: GLib.Variant) -> None:
        name, _old_owner, _new_owner = params.unpack()
        if name == BUS_NAME:
            GLib.timeout_add_seconds(1, refresh)

    bus.signal_subscribe(
        BUS_NAME,
        PROPERTIES_IFACE,
        'PropertiesChanged',
        OBJECT_PATH,
        None,
        Gio.DBusSignalFlags.NONE,
        on_properties_changed,
    )
    bus.signal_subscribe(
        'org.freedesktop.DBus',
        'org.freedesktop.DBus',
        'NameOwnerChanged',
        '/org/freedesktop/DBus',
        BUS_NAME,
        Gio.DBusSignalFlags.NONE,
        on_name_owner_changed,
    )

    def periodic_refresh() -> bool:
        updater.update()
        return True

    # Safety net only: real updates come from MPRIS DBus signals.
    # Si i3 crea el workspace despues del arranque, este retry evita polling agresivo.
    GLib.timeout_add_seconds(60, periodic_refresh)

    GLib.MainLoop().run()
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
