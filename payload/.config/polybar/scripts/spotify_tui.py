#!/usr/bin/env python3

import curses
import os
import subprocess
import sys
import textwrap
from typing import Any

from gi.repository import Gio, GLib


BUS_NAME = "org.mpris.MediaPlayer2.spotify"
OBJECT_PATH = "/org/mpris/MediaPlayer2"
PLAYER_IFACE = "org.mpris.MediaPlayer2.Player"
PROPERTIES_IFACE = "org.freedesktop.DBus.Properties"
WS9_NAME = "9"
BG = 16
SURFACE = 17
ACCENT = 18
TEXT = 19


def _proxy(interface: str) -> Gio.DBusProxy | None:
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


def is_available() -> bool:
    return _proxy(PLAYER_IFACE) is not None


def _get_property(name: str) -> Any:
    proxy = _proxy(PROPERTIES_IFACE)
    if proxy is None:
        return None

    result = proxy.call_sync(
        "Get",
        GLib.Variant("(ss)", (PLAYER_IFACE, name)),
        Gio.DBusCallFlags.NONE,
        1000,
        None,
    )
    value = result.unpack()[0]
    if isinstance(value, GLib.Variant):
        return value.unpack()
    return value


def _call_player(method: str) -> int:
    proxy = _proxy(PLAYER_IFACE)
    if proxy is None:
        return 1

    try:
        proxy.call_sync(method, None, Gio.DBusCallFlags.NONE, 1000, None)
        return 0
    except GLib.Error:
        return 1


def get_info() -> dict[str, Any]:
    if not is_available():
        return {
            "available": False,
            "status": "Offline",
            "title": "Spotify not running",
            "artist": "Open Spotify to enable controls",
            "album": "",
            "position": 0,
            "length": 0,
        }

    metadata = _get_property("Metadata") or {}
    status = _get_property("PlaybackStatus") or "Stopped"
    position = _get_property("Position") or 0

    title = metadata.get("xesam:title", "")
    artists = metadata.get("xesam:artist", [])
    album = metadata.get("xesam:album", "")
    length = metadata.get("mpris:length", 0)

    return {
        "available": True,
        "status": status,
        "title": str(title),
        "artist": ", ".join(artists) if isinstance(artists, (list, tuple)) else str(artists),
        "album": str(album),
        "position": int(position),
        "length": int(length),
    }


def format_time(microseconds: int) -> str:
    seconds = max(0, int(microseconds // 1_000_000))
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    if hours:
        return f"{hours}:{minutes:02d}:{seconds:02d}"
    return f"{minutes}:{seconds:02d}"


def progress_bar(position: int, length: int, width: int = 24) -> str:
    if length <= 0:
        return "-" * width
    ratio = max(0.0, min(1.0, position / length))
    filled = round(ratio * width)
    return "■" * filled + "·" * (width - filled)


def launch_terminal() -> int:
    if not shutil.which("gnome-terminal"):
        return 1

    terminal_cmd = " ".join(
        [
            "gnome-terminal",
            "--hide-menubar",
            "--title='Spotify Mini'",
            "--geometry=72x18",
            "--",
            "bash",
            "-lc",
            shlex.quote(
                "printf '\\033]10;#b8cdfe\\007\\033]11;#131520\\007\\033]12;#67c9e4\\007'; "
                + shlex.quote(sys.executable)
                + " "
                + shlex.quote(os.path.abspath(__file__))
                + " ui"
            ),
        ]
    )

    if shutil.which("i3-msg"):
        subprocess.Popen(["i3-msg", f"exec --no-startup-id {terminal_cmd}"])
    else:
        subprocess.Popen(
            [
                "gnome-terminal",
                "--hide-menubar",
                "--title=Spotify Mini",
                "--geometry=72x18",
                "--",
                "bash",
                "-lc",
                f"printf '\\033]10;#b8cdfe\\007\\033]11;#131520\\007\\033]12;#67c9e4\\007'; {shlex.quote(sys.executable)} {shlex.quote(os.path.abspath(__file__))} ui",
            ]
        )
    return 0


def draw_ui(stdscr: curses.window) -> None:
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(400)
    curses.start_color()
    curses.use_default_colors()
    try:
        curses.init_color(BG, 0x13 * 4, 0x15 * 4, 0x20 * 4)
        curses.init_color(SURFACE, 0x25 * 4, 0x2A * 4, 0x41 * 4)
        curses.init_color(ACCENT, 0x49 * 4, 0x61 * 4, 0xDA * 4)
        curses.init_color(TEXT, 0xB8 * 4, 0xCD * 4, 0xFE * 4)
        curses.init_pair(1, TEXT, BG)
        curses.init_pair(2, ACCENT, BG)
        curses.init_pair(3, TEXT, SURFACE)
    except curses.error:
        curses.init_pair(1, curses.COLOR_WHITE, -1)
        curses.init_pair(2, curses.COLOR_CYAN, -1)
        curses.init_pair(3, curses.COLOR_WHITE, -1)

    while True:
        info = get_info()
        stdscr.erase()
        height, width = stdscr.getmaxyx()
        title = " Spotify Mini "
        stdscr.bkgd(" ", curses.color_pair(1))
        stdscr.attron(curses.color_pair(2))
        stdscr.border()
        stdscr.attroff(curses.color_pair(2))
        stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
        stdscr.addstr(0, max(2, (width - len(title)) // 2), title)
        stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)

        lines = [
            ("Status", info["status"]),
            ("Track", info["title"]),
            ("Artist", info["artist"]),
            ("Album", info["album"]),
        ]

        row = 2
        for label, value in lines:
            wrapped = textwrap.wrap(str(value) if value else "-", max(10, width - 14)) or ["-"]
            stdscr.attron(curses.color_pair(2))
            stdscr.addstr(row, 2, f"{label:<8}")
            stdscr.attroff(curses.color_pair(2))
            stdscr.attron(curses.color_pair(1))
            stdscr.addstr(row, 11, wrapped[0])
            stdscr.attroff(curses.color_pair(1))
            row += 1
            for extra in wrapped[1:]:
                if row >= height - 5:
                    break
                stdscr.addstr(row, 11, extra, curses.color_pair(1))
                row += 1

        if height - row > 4:
            bar = progress_bar(info["position"], info["length"])
            timing = f"{format_time(info['position'])} / {format_time(info['length'])}"
            stdscr.addstr(row + 1, 2, bar[: max(0, width - 4)], curses.color_pair(2))
            stdscr.addstr(row + 2, 2, timing[: max(0, width - 4)], curses.color_pair(1))

        footer = "space play/pause | n next | p prev | s stop | o open spotify | q quit"
        stdscr.addstr(height - 2, 2, footer[: max(0, width - 4)], curses.color_pair(3))
        stdscr.refresh()

        key = stdscr.getch()
        if key == -1:
            continue
        if key in (ord("q"), 27):
            break
        if key == ord(" "):
            _call_player("PlayPause")
        elif key == ord("n"):
            _call_player("Next")
        elif key == ord("p"):
            _call_player("Previous")
        elif key == ord("s"):
            _call_player("Stop")
        elif key == ord("o") and shutil.which("spotify"):
            subprocess.Popen(["spotify"])


def main() -> int:
    command = sys.argv[1] if len(sys.argv) > 1 else "launch"

    if command == "launch":
        return launch_terminal()
    if command == "ui":
        curses.wrapper(draw_ui)
        return 0
    if command == "info":
        info = get_info()
        print(
            f"{info['status']}\n{info['title']}\n{info['artist']}\n{info['album']}\n"
            f"{format_time(info['position'])}/{format_time(info['length'])}"
        )
        return 0
    if command == "play-pause":
        return _call_player("PlayPause")
    if command == "next":
        return _call_player("Next")
    if command == "previous":
        return _call_player("Previous")
    if command == "stop":
        return _call_player("Stop")

    print("Usage: spotify_tui.py [launch|ui|info|play-pause|next|previous|stop]", file=sys.stderr)
    return 1


if __name__ == "__main__":
    import shutil
    import shlex

    raise SystemExit(main())
