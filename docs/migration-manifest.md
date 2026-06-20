# Migration Manifest

Use this manifest when moving the daily workstation to a new Linux Mint/X11 machine. Keep the desktop and agent setup reproducible, then restore personal data separately.

## What This Repo Owns

| Area | Source | Restore path |
|------|--------|--------------|
| STACKI3 desktop config | `payload/` | `$HOME/` via `install.sh` |
| i3, Polybar, Rofi, Dunst, Picom | `payload/.config/` | `$HOME/.config/` |
| Shell/tmux defaults | `payload/.zshrc`, `payload/.tmux.conf` | `$HOME/` |
| Daily helper commands | `payload/.local/bin/` | `$HOME/.local/bin/` |
| Theme definitions | `payload/.config/stack-theme/` | `$HOME/.config/stack-theme/` |

## Restore After STACKI3

Copy these after running the STACKI3 installer and dependency script:

| Data | Recommended restore |
|------|---------------------|
| Obsidian vault | `rsync -a --info=progress2 old:~/obsidian-vault/ ~/obsidian-vault/` |
| Git projects | `rsync -a --info=progress2 old:~/git/ ~/git/` |
| Documents | `rsync -a --info=progress2 old:~/Documentos/ ~/Documentos/` |
| Scripts not in STACKI3 | Review before copying into `~/.local/bin` |
| Browser bookmarks | Prefer account sync or explicit export/import |

Do not restore an entire old `$HOME` over the new one. It will overwrite freshly deployed configs and can bring stale cache, sockets, machine IDs, and secrets.

## Secrets And Credentials

Restore these manually or through a password manager:

| Secret | Safer approach |
|--------|----------------|
| SSH keys | Copy `~/.ssh` with permissions preserved, then run `chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/*` as needed |
| GitHub auth | Re-run `gh auth login` or restore from password manager |
| Cloud credentials | Recreate with provider CLIs where practical |
| `.env` files | Restore per project, never from broad home sync |
| Bitwarden/export files | Keep encrypted and remove temporary exports after import |

## Optional State

These are useful but not required for a clean transition:

| State | Notes |
|-------|-------|
| Atuin history | Prefer `atuin sync` if enabled; otherwise copy only after checking for sensitive commands |
| Browser profile | Prefer sync; full profile copy can break between versions |
| Fonts/icons/themes | Copy only the custom sets you actively use |
| `~/.config/BraveSoftware` | Optional and large; prefer selective restore |
| `~/.local/share/applications` | Review before copying, because desktop files often contain machine-local paths |

## Preflight Checklist

- [ ] `space-stack` is published or packaged.
- [ ] `scripts/install-dependencies.sh` was reviewed.
- [ ] `scripts/install-lazyjournal.sh` was run if log browsing is part of the daily setup.
- [ ] `scripts/package.sh` was run if using an offline transfer.
- [ ] Personal data is copied separately from config.
- [ ] Secrets are restored manually.
- [ ] `scripts/verify-install.sh` passes on the new machine.
