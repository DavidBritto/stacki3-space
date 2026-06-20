# Dependencies

This repo packages a working config layer. Dependency installation is intentionally separate from config deployment so a fresh machine can be reviewed before packages are installed.

The lists below are split into:
- **APT packages** verified against the current system
- **External/manual tools** used by the setup but not mapped here to an apt package from this machine

## Quick path

Preview the dependency plan:

```bash
scripts/install-dependencies.sh
```

Install the APT package set on Linux Mint / Debian-like systems:

```bash
scripts/install-dependencies.sh --apply
```

## APT packages

### Core desktop

```bash
sudo apt install \
  i3-wm picom polybar rofi dunst lightdm slick-greeter \
  xss-lock i3lock feh dex flameshot network-manager \
  gnome-terminal nemo zathura kitty
```

### Shell / terminal workflow

```bash
sudo apt install \
  tmux zsh fzf zoxide ripgrep fd-find eza git rsync xsel xclip xdotool htop python3-gi \
  ffmpeg poppler-utils p7zip-full chafa
```

### Audio / network / media helpers

```bash
sudo apt install \
  alsa-utils network-manager imagemagick curl netcat-openbsd playerctl
```

## Why these packages matter

- `i3-wm` — window manager
- `picom` — compositor
- `polybar` — status bar
- `rofi` — launcher and menu frontend
- `dunst` — notifications
- `lightdm` + `slick-greeter` — login manager/greeter
- `xss-lock` + `i3lock` — lock flow
- `feh` — wallpaper
- `dex` — XDG autostart loader
- `flameshot` — screenshots
- `network-manager` — provides `nmcli` and `nmtui`
- `gnome-terminal` — terminal used by launchers and overlays
- `kitty` — canonical terminal for the i3/tmux workflow
- `nemo` — GUI file manager
- `zathura` — PDF viewer
- `tmux` — main workflow hub
- `zsh` — interactive shell
- `fzf` — shell/menu completion helpers
- `zoxide` — smarter `cd` replacement
- `ripgrep` — fast project text search via `rg`
- `fd-find` — Ubuntu package for `fd`; stacki3 ships an `fd` wrapper around `fdfind`
- `eza` — modern `ls` replacement with icons/tree aliases
- `git` — repos and install flow
- `rsync` — payload sync in `install.sh`
- `xsel` — clipboard backend for `tmux-copy`
- `xclip` — extra clipboard backend for `tmux-copy`
- `xdotool` — X11 focus detection and terminal paste helper for the Space update action
- `htop` — fallback system monitor if `btop` isn't installed
- `python3-gi` — Python Gio/GLib bindings for Spotify MPRIS helpers and workspace naming
- `ffmpeg` — media metadata/previews used by Yazi
- `poppler-utils` — provides `pdftoppm` for PDF previews in Yazi
- `p7zip-full` — archive extraction/listing backend used by Yazi
- `chafa` — terminal image/thumbnail fallback used by Yazi
- `alsa-utils` — provides `alsamixer`
- `imagemagick` — provides `convert` used by `lock.sh`
- `curl` — bootstrap install and tmux net debug helper
- `netcat-openbsd` — provides `nc` used by tmux net debug helper
- `playerctl` — media command helper for current/future media integrations

## External / manual tools

These are used by the current setup but are **not** pinned here to apt package names from this machine:

- `starship`
- `atuin`
- `yazi`
- `lazygit`
- `lazyjournal`
- `greenclip`
- `resvg` for the fullest Yazi SVG preview coverage, depending on the chosen Yazi install/package source

Install or update `lazyjournal` with:

```bash
scripts/install-lazyjournal.sh
```

Recommendation: document your preferred installation method for the remaining external tools before publishing, or keep them as optional tools.

## Optional but recommended

- `qutebrowser`
- `brave-browser` or `brave-origin-nightly`
- `wl-copy` as an extra clipboard backend for `tmux-copy` if a Wayland session is ever added

## Notes

- The system currently uses **Brave Nightly** as the default browser, but browser package names vary depending on install source.
- `btop` is **not** currently installed on this machine; the overlay falls back to `htop` or `top`.
- `tmux-copy` already falls back across multiple clipboard tools:
  - `wl-copy`
  - `xsel`
  - `xclip`
  - `clip.exe`

## Publish suggestion

Keep `scripts/install-dependencies.sh` and this document in sync whenever packages are added or removed.
