# STACKI3 — Agent Stack File

## Mission
This repo packages a **real keyboard-first i3 desktop on Linux Mint/X11**. Treat this file as the **current operating model**, not as a wishlist.

## Core identity
- **Base OS:** Linux Mint
- **Working session:** i3wm on X11
- **Display manager:** LightDM
- **Inherited desktop layer still installed:** Cinnamon
- **Compositor:** Picom
- **Launcher / hubs:** `space` CLI + Rofi + `deskmenu`
- **Notifications:** Dunst
- **Status bar:** Polybar
- **Terminal:** Kitty
- **Shell:** Zsh + Zinit
- **Prompt:** Oh My Posh
- **Multiplexer:** tmux
- **History search:** Atuin
- **Directory jumping:** zoxide
- **Shell search/navigation:** fzf, ripgrep (`rg`), fd wrapper, eza, `try`

## Real workflow
The actual workflow is:
1. launch a terminal
2. land in tmux
3. use i3 for windows and global menus
4. keep floating TUI overlays only for a few transient tasks

Important consequence: **Yazi is the canonical file manager; use it directly from shell/tmux or through optional stack launchers.**

## Canonical apps
- **Default web browser / XDG:** Brave Nightly (`brave-origin-nightly.desktop`)
- **Quick keyboard browser binding:** qutebrowser (`mod+b`)
- **Editor:** terminal/Neovim workflow; GUI editors are user choice
- **GUI file manager fallback:** Nemo
- **PDF handler:** Zathura
- **Git TUI:** lazygit
- **Logs TUI:** lazyjournal
- **System monitor overlay:** `htop` label, with `top` fallback if `htop` isn't installed
- **File manager in terminal flow:** Yazi
- **Audio TUI:** alsamixer
- **Network TUI:** nmtui

Installed but **not canonical / not central**:
- `aerc`
- `calcurse`

## UX principles
1. **Keyboard first**
2. **Terminal + tmux first**
3. **TUI before extra GUI clutter**
4. **Low visual noise**
5. **Only keep shortcuts that solve real friction**

## Visual language
- **Theme family:** `deep-space / space-purple`
- **Default theme:** `deep-space`
- **Base:** `#000000`
- **Surface:** `#050711`
- **Elevated:** `#0b1020`
- **Accent:** `#4961da`
- **Violet:** `#7c5cff`
- **Text:** `#b8cdfe`
- **Shape language:** square, border-driven, no bubbly UI
- **Dunst:** dark, square, shadowless
- **Rofi:** rectangular, terminal-like
- **Polybar:** compact modules; focused workspace uses `| %name% |`
- **Status principle:** quiet when healthy; spend attention only on actionable state

## Main interaction surfaces
### i3
- tiling navigation
- numeric workspaces `1..10`
- screenshot / volume / media keys
- lock shortcut

Volume/media keys use `XF86Audio*` only. Do not bind bare `F2`/`F3`/`F4`; those fire without `Fn` on this keyboard.

### Workspace anchors
- main terminal (`kitty --class stack-main-terminal`) → `1:terminal`
- Spotify (`class=Spotify`) → workspace `9`, renamed by `spotify_workspace_name.py` to `9: Track · Artist ♪` from MPRIS metadata

Contextual windows intentionally **do not** get pinned:
- a normal Kitty terminal opens on the current workspace and skips auto-tmux attach; only the dedicated “main terminal” binding is pinned to workspace `1:terminal`
- Brave and other regular GUI apps open on the current workspace by default
- Nemo remains a fallback for GUI-only file workflows; normal file browsing should use Yazi.
- Helper / panel terminals use a separate WM_CLASS (`stack-context`) so manuals and transient TUIs do not get sent to workspace `1`.
- `network-tui` uses `stack-network-panel` so `nmtui` is centered without inheriting the large generic `stack-panel` rule.
- the calendar TUI uses `stack-calendar-panel` and opens visible/centered, not in scratchpad.


### Global theme switcher
`~/.local/bin/stack-theme` is the canonical theme control surface.

Commands:
- `stack-theme backup` → save live config snapshot
- `stack-theme list` → show available themes
- `stack-theme current` → show active theme
- `stack-theme apply deep-space` → apply the current black deep-space theme
- `stack-theme apply space-purple` → apply the previous purple space palette
- `stack-theme restore-last` → restore files from the latest backup

The switcher writes generated color files and updates i3, Polybar, Rofi, Dunst, Picom, tmux, Kitty, Zsh/Oh My Posh, GTK/Nemo and terminal/editor theme files shipped by the stack. Nemo stays on `CrewDragon-Y` in both themes by preference. The selectable theme names are `deep-space` and `space-purple`; `oceano` survives only in legacy component path names such as `rofi/oceano.rasi` and `polkit-oceano`.

### SPACE command surface
`~/.local/bin/space` is the main Omarchy-like command surface for STACKI3. It wraps the existing helpers instead of replacing stable pieces.

Commands:
- `space search` → global command/project/window/workspace search through Rofi
- `space menu [category]` → direct category menu access
- `space files` → optional launcher for the Yazi file manager surface
- `space theme {list|current|apply <name>|restore-last}` → theme control via `stack-theme`
- `space wall {next|prev|random|apply-last|apply <path>}` → wallpaper control via `stack-wall`
- `space bar restart` → relaunch Polybar
- `space system reload` → reload i3
- `space doctor` → check core desktop commands

### Shell tools
STACKI3 mirrors the useful shell layer from Omarchy without changing the base distro:

- `fzf` powers fuzzy selection; `ff` opens a file picker with preview.
- `zoxide` initializes in Zsh and replaces slow manual `cd` habits.
- `ripgrep` (`rg`) is the canonical text search.
- `fd` is provided as `~/.local/bin/fd`, wrapping Ubuntu's `fdfind` from `fd-find`.
- `eza` backs `ls`, `ll`, `lt`, `lsa`, and `lta`.
- `lazyjournal` is the canonical logs TUI for journald, system logs and container logs.
- `try <name>` creates and enters `~/Work/tries/YYYY-MM-DD-<name>`.

Important: `try` exists as a Zsh function because only a function can `cd` the current shell. A script fallback also exists at `~/.local/bin/try` for non-interactive use.

SSH port forwarding functions mirror Omarchy:
- `fip <host> <port...>` forwards remote localhost ports to local localhost via SSH.
- `dip <port...>` disconnects forwarded ports.
- `lip` lists active SSH localhost forwards.

### Rofi hub
`~/.local/bin/deskmenu` remains the Rofi backend and compatibility menu.

The public-facing menu uses category glyphs and minimal back copy:
- `󰍜 system`
- `󰾆 compositor`
- `󰂚 notify`
- `󰕾 audio`
- `󰖩 network`
- `󰉋 mounts`
- `󰅌 clipboard`
- `󰊢 projects`
- `󰍹 windows`
- `󰹑 workspaces`
- `󰏘 theme`
- `󰋖 help`
- back item: `← volver`

Categories:
- `projects`
- `windows`
- `workspaces`
- `panels`
- `audio`
- `network`
- `files`
- `mounts`
- `clipboard`
- `system`
- `help`

### TUI overlays that are still worth keeping
`~/.local/bin/tui-panel` launches transient overlays in Kitty with explicit deep-space color overrides and remains for:
- `htop` (with `top` fallback)
- `lazygit`
- `audio-mixer`
- `network-tui`
- `clipboard-view`
- `quick-notes`
- `files-yazi`

Dedicated panel classes:
- `stack-panel` → generic large overlays
- `stack-network-panel` → `nmtui`, no forced large resize
- `stack-calendar-panel` → compact calendar launched from the Polybar date
- `stack-files-panel` → Yazi file manager surface

Theme policy:
- Kitty overlay launchers force the deep-space palette explicitly.
- `nmtui` receives deep-space-like `NEWT_COLORS`.
- Do not theme each TUI individually unless a concrete mismatch is observed.

### tmux helpers that are part of the real setup
- `~/.local/bin/tmux-copy`
- `~/.local/bin/tmux-net-health`
- `~/.local/bin/tmux-net-debug`

tmux bindings worth treating as canonical:
- `prefix + Space` → choose-tree popup
- `prefix + N` → quick network debug popup

### Spotify workspace watcher
`payload/.config/i3/spotify_workspace_name.py` is canonical. It uses Spotify MPRIS over Gio/GLib DBus, not `playerctl`, to avoid adding an unnecessary dependency. It updates workspace 9 on DBus metadata changes and keeps only a 60-second safety retry. Current label shape: `9: Track · Artist ♪`.

Music is intentionally **not** duplicated in Polybar. The previous music bar module was removed because workspace 9 already carries the useful context.

### Polybar status modules
Current right-side modules:

```ini
modules-right = ram cpu volume power
```

Policy:
- no LAN/network module in the bar; wired-network status is not useful enough for persistent space
- no music module in the bar; Spotify state lives in workspace 9
- RAM and CPU use normal foreground
- updates are quiet at zero
- when updates exist, `date_updates_status.sh` prints a small violet `↻` immediately to the right of the clock/date, matching the Omarchy-style update affordance
- clicking `↻` opens `space menu system`
- `update apps` asks for confirmation, validates terminal focus through the i3 tree, copies the apt command, and pastes it with `xdotool` without pressing Enter
- clicking the date opens `calendar_tui.sh`; this is implemented through Polybar action tags in `date_updates_status.sh`, not `internal/date` click handling

### Calendar TUI
`payload/.config/polybar/scripts/calendar_tui.sh` is canonical for the date click.

Behavior:
- opens Kitty with `--class stack-calendar-panel`, explicit deep-space color overrides, and no scrollbar/scrollback
- uses compact Kitty sizing plus i3 title-based centering
- prefers configured `ikhal`/`khal`
- falls back to `ncal`, `cal`, then `python3 calendar.month()`
- waits for `q` before closing when using non-interactive fallbacks

### Explicitly non-canonical shortcuts / flows
Agents should **not** reintroduce these as first-class features unless asked:
- dedicated i3 bindings for `yazi`
- dedicated i3 bindings for mail
- task dashboard launchers
- treating panel launchers as more important than tmux

## Important keybindings
- `mod+Enter` → terminal on current workspace, without forced tmux attach
- `mod+Shift+Enter` → main tmux terminal on workspace `terminal`
- `mod+d` → app launcher
- `mod+p` → SPACE global search
- `mod+Shift+p` → project sessionizer through SPACE
- `mod+grave` → TUI overlay menu
- `mod+Shift+v` → clipboard menu
- `mod+F1` → manuals
- `mod+b` → qutebrowser
- `mod+Shift+x` → lock
- `Print` → Flameshot GUI

## Repo payload intent
`payload/` contains a portable version of the real config layer:
- i3 config and helper scripts
- Polybar config and scripts
- Dunst config
- Picom config
- Rofi config/themes
- shortcut/manual pages
- launcher scripts in `.local/bin`
- tmux config and helper scripts
- shell wrappers/helpers (`fd`, `try`)

## Constraints / caveats
- X11 + i3 only
- Linux Mint is still the practical base
- Cinnamon remains installed in the real machine for compatibility
- this repo packages the working config layer, not a full dependency bundle
- do not assume every installed TUI is a core part of the workflow

Operational notes:
- Atuin is intentionally lean: no daemon autostart, no sync records, no AI, no failed-command storage, noisy commands filtered.
- Polybar date/update behavior lives in `date_updates_status.sh`; updates show as a violet `↻` beside the date only when available.
- GUI process verification for i3/Polybar/Kitty must run outside sandboxed command sessions.

## Canonical files
- `payload/.config/i3/config`
- `payload/.config/i3/lock.sh`
- `payload/.config/i3/spotify_workspace_name.py`
- `payload/.config/polybar/config.ini`
- `payload/.config/polybar/launch.sh`
- `payload/.config/polybar/scripts/cpu_status.sh`
- `payload/.config/polybar/scripts/ram_status.sh`
- `payload/.config/polybar/scripts/volume_status.sh`
- `payload/.config/polybar/scripts/spotify_tui.py`
- `payload/.config/polybar/scripts/updates_status.sh`
- `payload/.config/polybar/scripts/calendar_tui.sh`
- `payload/.config/stack-theme/themes/deep-space.json`
- `payload/.config/stack-theme/themes/space-purple.json`
- `payload/.config/dunst/dunstrc`
- `payload/.config/picom/picom.conf`
- `payload/.config/rofi/config.rasi`
- `payload/.config/rofi/oceano.rasi`
- `payload/.config/shortcuts/pages/*.txt`
- `payload/.config/polkit-oceano/gtk-3.0/settings.ini`
- `payload/.local/bin/space`
- `payload/.local/bin/deskmenu`
- `payload/.local/bin/fd`
- `payload/.local/bin/try`
- `payload/.local/bin/stack-theme`
- `payload/.local/bin/tui-panel`
- `payload/.local/bin/shortcuts-help`
- `payload/.local/bin/polkit-agent-oceano`
- `payload/.local/bin/apply-slick-greeter-oceano`
- `payload/.local/bin/tmux-copy`
- `payload/.local/bin/tmux-net-health`
- `payload/.local/bin/tmux-net-debug`
- `payload/.tmux.conf`
- `install.sh`

## Agent guidance
Good changes:
- keep docs faithful to the real stack
- improve installer portability
- preserve terminal+tmux as the center of gravity
- prefer native capabilities and existing helpers before adding dependencies
- document optional dependencies honestly
- preserve default tiling so mixed apps (for example Brave + another app) split the workspace instead of forcing extra window-switcher UX

Bad changes:
- reintroducing non-essential launchers as “core UX”
- documenting installed-but-unused tools as primary workflow
- replacing the square terminal-like visual language
