# ░█▀▀░▀█▀░█▀█░█▀▀░█░█░▀█▀
# ░▀▀█░░█░░█▀█░█░░░█▀▄░░█░
# ░▀▀▀░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀

> **STACKI3** — a keyboard-first i3 desktop package built around **terminal + tmux** on Linux Mint/X11.

[![WM](https://img.shields.io/badge/WM-i3-4961da?style=flat-square)](#)
[![Display](https://img.shields.io/badge/Display-X11-252a41?style=flat-square)](#)
[![Core](https://img.shields.io/badge/Core-terminal%2Btmux-4961da?style=flat-square)](#)
[![Launcher](https://img.shields.io/badge/Launcher-Rofi-67c9e4?style=flat-square)](#)
[![Notify](https://img.shields.io/badge/Notify-Dunst-4a5a7a?style=flat-square)](#)

---

## What is STACKI3?

STACKI3 packages a real desktop workflow built on:

- **i3wm** for windows and workspaces
- **Kitty + tmux** as the actual work hub
- **Zsh + Zinit + Oh My Posh** for the shell layer
- **SPACE CLI + Rofi/deskmenu** for global search, menus and command surfaces
- **Polybar** for compact status output
- **Dunst** for dark square notifications
- **Picom** for restrained compositor behavior
- **Omarchy-like shell tools** (`fzf`, `zoxide`, `rg`, `fd`, `eza`, `try`) for daily terminal navigation
- **qutebrowser** as a quick keyboard browser binding
- **Zathura** for PDFs
- **Yazi / lazygit / alsamixer / nmtui** as supporting TUI tools

This is **not** an “everything gets its own i3 binding” desktop.

The model is:
1. open a terminal
2. land in tmux
3. work there
4. use i3, Rofi and overlays only where they remove real friction

---

## Design goals

- keyboard-first
- terminal-first
- tmux-centered
- low visual noise
- square dark visual language
- practical menus instead of gimmicky launch surfaces
- safe Omarchy-inspired functions without migrating to Hyprland/Wayland

---

## Core bindings

- `mod+Enter` → terminal on current workspace, without forced tmux attach
- `mod+Shift+Enter` → main tmux terminal on workspace `terminal`
- `mod+d` → app launcher
- `mod+p` → SPACE global search
- `mod+'` → window switcher
- `mod+Shift+p` → project sessionizer through SPACE
- `mod+grave` → TUI overlay menu
- `mod+Shift+v` → clipboard menu
- `mod+F1` → built-in manuals
- `mod+b` → qutebrowser
- `mod+Shift+x` → lock

Workspace intent:
- `terminal` → optional main terminal anchor
- `browser` / `code` → named contextual workspaces
- `9` → Spotify, renamed from MPRIS metadata as `9: Track · Artist ♪`
- everything else opens contextually on the current workspace unless explicitly assigned or launched as an overlay/panel

---

## Polybar status model

The bar is intentionally quiet. It shows operational signals only when they matter:

- left: i3 workspaces
- center: date/time; click the date to open the compact Space calendar TUI
- right: RAM, CPU, volume and power
- updates are quiet when the count is `0`
- when updates exist, a small violet `↻` appears immediately to the right of the date/time, matching the Omarchy circle-arrow affordance
- LAN/network and music modules are intentionally removed from the bar

Music context lives in workspace `9` through the Spotify workspace watcher, not as duplicated bar text.

---

## What stays on purpose

### TUI overlays

These remain because they solve occasional friction well:

- `htop` overlay label, with fallback to `top`
- `lazygit`
- `audio-mixer`
- `network-tui`
- `clipboard-view`
- `quick-notes`
- compact deep-space Kitty calendar from Polybar date click

All transient TUI overlays launch in Kitty with explicit `deep-space` colors. `nmtui` also receives a matching `NEWT_COLORS` palette.

These are **not** treated as the center of the workflow:

- `yazi` (used from shell/tmux)
- `aerc`
- `calcurse`

### tmux helpers

Included helpers:

- `tmux-copy` — copy-mode integration with system clipboard backends
- `tmux-net-health` — compact IP/latency status segment
- `tmux-net-debug` — popup diagnostics for quick network checks

Canonical additions:

- `prefix + Space` → choose-tree popup
- `prefix + N` → network debug popup

### Shell tools

STACKI3 now mirrors the useful shell-tool layer from Omarchy while staying on Linux Mint/X11:

- `ff` → `fzf` file picker with preview
- `zoxide` → smarter directory jumping
- `rg` → fast text search
- `fd` → wrapper around Ubuntu's `fdfind`
- `eza` → `ls`, `ll`, `lt`, `lsa`, `lta`
- `try <name>` → dated experiment directory under `~/Work/tries`

`try` is both a Zsh function, so it can `cd` the current shell, and a `~/.local/bin/try` fallback script.

### SSH port forwarding

Omarchy-style shell functions are available in Zsh:

- `fip <host> <port...>` → forward one or more remote localhost ports to local localhost through SSH
- `dip <port...>` → disconnect forwarded ports
- `lip` → list active SSH localhost forwards

Example:

```bash
fip nyc-dev 3000
# localhost:3000 now reaches nyc-dev:3000
```

---

## Repository layout

```text
stacki3/
├── install.sh
├── stack.md
├── README.md
├── docs/
│   └── dependencies.md
├── dist/
└── payload/
    ├── .config/
    │   ├── i3/
    │   ├── polybar/
    │   ├── dunst/
    │   ├── picom/
    │   ├── rofi/
    │   ├── nvim/
    │   ├── shortcuts/
    │   ├── stack-theme/
    │   └── polkit-oceano/        # legacy component name, not a selectable theme
    ├── .local/bin/
    └── .tmux.conf
```

---

## Install

### Fresh machine

Follow [`docs/new-machine-install.md`](./docs/new-machine-install.md) for a complete Linux Mint/X11 transition: dependencies, STACKI3 install, data restore and verification.

One-command GitHub bootstrap for a fresh Linux Mint/Debian-like machine:

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/stacki3/main/install.sh | bash -s -- --deps
```

Preview dependency installation:

```bash
scripts/install-dependencies.sh
```

Install dependencies:

```bash
scripts/install-dependencies.sh --apply
```

### Local test

```bash
git clone https://github.com/Gentleman-Programming/stacki3.git stacki3
cd stacki3
bash install.sh
```

`bash install.sh` deploys the config payload only. To install APT dependencies and then deploy the config, run:

```bash
bash install.sh --deps
```

By default the installer preserves an existing `~/.zshrc` and only adds safe STACKI3 aliases such as `lj` for `lazyjournal`. To intentionally replace `~/.zshrc` with the packaged version on a clean machine, run:

```bash
STACKI3_OVERWRITE_ZSHRC=1 bash install.sh
```

### Remote bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/stacki3/main/install.sh | bash -s -- --deps
```

For forks or private repos:

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/stacki3/main/install.sh \
  | STACKI3_REPO_URL=https://github.com/me/stacki3.git bash -s -- --deps
```

### Offline package

Create a transferable package:

```bash
scripts/package.sh
```

Copy only the generated archive to the target machine:

```bash
scp dist/stacki3-package.tar.gz user@target:~/
```

On the target machine:

```bash
tar -xzf ~/stacki3-package.tar.gz
cd ~/stacki3-package
bash install.sh --deps
```

Use `bash install.sh` without `--deps` only when dependencies are already installed and you only want to deploy the config payload.

---


## SPACE command surface

`space` is the canonical daily CLI for the desktop layer. It wraps the existing stable helpers instead of replacing them:

```bash
space search
space menu
space menu projects
space theme list
space theme current
space theme apply deep-space
space wall next
space bar restart
space system reload
space doctor
```

Compatibility helpers remain available: `deskmenu`, `stack-theme`, `stack-wall`, `tui-panel`, `fd` and `try`. Treat the lower-level helpers as implementation details unless you are debugging a specific layer.

`deskmenu` uses category glyphs and a minimal `← volver` affordance so the public menu reads like a real command surface, not a personal script dump.

## Theme switching

STACKI3 includes a global theme switcher. Current themes:

- `deep-space` — current black deep-space theme.
- `space-purple` — alternate purple space palette.

```bash
stack-theme list
stack-theme current
stack-theme apply deep-space
stack-theme apply space-purple
stack-theme restore-last
```

Every apply creates a timestamped backup in `~/.local/state/stacki3-theme/backups/`. The switcher applies the shared palette to i3, Polybar, Rofi, Dunst, Picom, tmux, Kitty, Zsh/Oh My Posh, GTK/Nemo and terminal/editor theme files shipped by the stack. The installer also deploys a LazyVim-compatible Neovim plugin that pins the editor to the `deep-space` palette. Nemo intentionally stays on `CrewDragon-Y` for both themes.

The selectable theme names are only `deep-space` and `space-purple`. Legacy paths such as `rofi/oceano.rasi` and `polkit-oceano` are component names, not active theme names.

## What the installer deploys

- i3 config + helper scripts, including the Spotify workspace watcher
- Polybar config + scripts
- Dunst config
- Picom config
- Rofi theme/config
- Neovim/LazyVim deep-space theme plugin
- stack-theme theme definitions for `deep-space` and `space-purple`
- shortcut/manual pages
- desktop helper scripts in `~/.local/bin`
- tmux config + clipboard/network helpers
- shell tool wrappers (`fd`, `try`)

The installer creates timestamped backups before overwriting files.

---

## Dependencies

See [`docs/dependencies.md`](./docs/dependencies.md).

This repo intentionally keeps dependency installation separate from config deployment.

For migration planning, see [`docs/migration-manifest.md`](./docs/migration-manifest.md).

## Current maintenance notes

- Atuin uses a lean local profile: no daemon autostart, no sync records, no AI, no failed-command storage, and noisy commands filtered.
- Polybar date/update status is implemented by `date_updates_status.sh`, not `internal/date`, so click handling stays explicit and reliable.
- GUI process verification must happen outside the Codex sandbox when relaunching Polybar, i3, or Kitty windows.

---

## Operating model

Read [`stack.md`](./stack.md) first.

That file defines:
- what is truly central
- what is merely installed
- which shortcuts are canonical
- why terminal + tmux is the center of gravity

---

## Current assumptions

- Linux Mint / Ubuntu-like userland
- X11 session
- i3 as the real working session
- Cinnamon still present for compatibility, but not treated as the active UX layer

---

## Publish checklist

- [x] replace bootstrap placeholders in `README.md`, `install.sh` and `PACKAGE_LINK.txt`
- [ ] confirm the final GitHub owner/repo before public release
- [ ] add screenshots to the repo
- [ ] test `install.sh` in a clean user session
- [ ] verify wallpaper path and Slick Greeter styling after reboot
- [ ] regenerate `dist/stacki3-package.tar.gz`
- [ ] push to GitHub
