# Repository Guidelines

## Project Structure & Module Organization

STACKI3 is a Linux Mint/X11 i3 desktop package. The installer deploys files from `payload/` into the user’s home directory.

- `install.sh` — local or remote installer; backs up existing dotfiles and syncs `payload/`.
- `payload/.config/` — desktop configuration for i3, Polybar, Dunst, Picom, Rofi, GTK, qutebrowser, Yazi, systemd user units, and themes.
- `payload/.local/bin/` — executable helper scripts such as `stack-theme`, `deskmenu`, `tui-panel`, and tmux helpers.
- `payload/.tmux.conf` and `payload/.zshrc` — terminal workflow defaults.
- `docs/` — dependency and reference documentation.
- `dist/` — generated package archives; do not edit by hand.

## Build, Test, and Development Commands

```bash
bash install.sh
```
Installs from the local checkout when `payload/` exists. It creates timestamped backups under `~/.local/state/stacki3/backups/`.

```bash
bash -n install.sh
find payload -type f -name '*.sh' -exec bash -n {} +
```
Checks shell syntax for the installer and shell scripts.

```bash
python3 -m py_compile payload/.config/polybar/scripts/spotify_tui.py payload/.config/i3/spotify_workspace_name.py
```
Validates Python helpers for Spotify controls and workspace naming.

```bash
STACKI3_REPO_URL=<repo-url> STACKI3_REPO_REF=<branch> bash install.sh
```
Tests the remote clone/install path.

## Coding Style & Naming Conventions

Use Bash with `set -euo pipefail` for installer-style scripts. Prefer small functions, quoted variables, and explicit dependency checks with `command -v`. Keep helper names lowercase and hyphenated, matching existing commands like `tmux-net-health` and `stack-theme`. Python files should use 4-space indentation. For new features, prefer native platform capabilities and existing repo helpers before adding dependencies; every dependency increases install size, memory/process overhead, and maintenance cost. Document unavoidable dependencies in `docs/dependencies.md`.

## Testing Guidelines

There is no formal test suite. Validate changes with syntax checks, then run the affected helper manually in an X11/i3 session when behavior depends on desktop services. For config changes, reload the target service: `i3-msg reload`, restart Polybar via `payload/.config/polybar/launch.sh`, or restart Dunst/Picom as appropriate.

## Desktop Workflow Notes

Spotify is assigned to workspace 9 with `assign [class="^Spotify$"] number 9`. The `payload/.config/i3/spotify_workspace_name.py` watcher updates the workspace label from Spotify MPRIS metadata via Gio/GLib DBus signals, with only a 60-second safety retry. Keep `python3-gi` documented when touching this flow.

## Commit & Pull Request Guidelines

This checkout does not expose readable Git history, so follow conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`. Never add AI attribution or `Co-Authored-By` trailers. PRs should describe the changed workflow, list manual verification commands, mention affected paths, and include screenshots for visual changes.

## Security & Configuration Tips

Do not commit machine-specific secrets, tokens, or private paths. Keep dependency installation separate from config deployment unless the README and `docs/dependencies.md` are updated together.
