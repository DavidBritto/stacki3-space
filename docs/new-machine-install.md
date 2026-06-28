# New Machine Install

This is the clean path for rebuilding the workstation on another Linux Mint/X11 machine.

## 1. Install Linux Mint

Install Linux Mint normally, boot once into Cinnamon, connect to the network, and apply system updates:

```bash
sudo apt update && sudo apt upgrade
sudo apt install -y git curl rsync
```

## 2. Get STACKI3-Space with APT

Add the STACKI3-Space repository and install the package:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://davidbritto.github.io/stacki3-space/stacki3-space-archive-keyring.asc \
  | sudo tee /etc/apt/keyrings/stacki3-space.asc >/dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/stacki3-space.asc] https://davidbritto.github.io/stacki3-space stable main" \
  | sudo tee /etc/apt/sources.list.d/stacki3-space.list >/dev/null
sudo apt update
sudo apt install stacki3-space
stacki3-space apply --deps
```

If the repo is not signed yet, use this temporary source line instead:

```bash
echo "deb [trusted=yes arch=amd64] https://davidbritto.github.io/stacki3-space stable main" \
  | sudo tee /etc/apt/sources.list.d/stacki3-space.list >/dev/null
```

APT updates the packaged copy in `/usr/share/stacki3-space`. Run `stacki3-space apply` as your user whenever you want to sync the latest packaged config into `$HOME`.

## 3. Development or Offline Install

Clone this repo from your own git remote and install dependencies plus the config payload:

```bash
git clone https://github.com/DavidBritto/stacki3-space.git stacki3-space
cd stacki3-space
bash install.sh --deps
```

For an offline, unpublished, or SSH-only transfer, create the package on the source machine:

```bash
scripts/package.sh
scp dist/stacki3-space-package.tar.gz user@target:~/
```

Then on the target machine:

```bash
tar -xzf ~/stacki3-space-package.tar.gz
cd ~/stacki3-space-package
bash install.sh --deps
```

## 4. Review Dependencies Separately

If you want to review packages before installing them, clone or extract the repo first and preview the plan:

```bash
scripts/install-dependencies.sh
```

Install:

```bash
scripts/install-dependencies.sh --apply
```

Install the log viewer TUI:

```bash
scripts/install-lazyjournal.sh
```

## 5. Deploy Config Only

From the repo checkout:

```bash
bash install.sh
```

From the APT package:

```bash
stacki3-space apply
```

This mode deploys config only. It does not install desktop packages.

The installer keeps an existing `~/.zshrc` by default. On a clean machine where you want the packaged STACKI3-Space shell profile, use:

```bash
STACKI3_SPACE_OVERWRITE_ZSHRC=1 bash install.sh
```

Log out and select the i3 session from LightDM. Then run:

```bash
space doctor
stack-theme current
scripts/verify-install.sh
```

For an APT install, use:

```bash
stacki3-space doctor
```

## 6. Restore Daily Data

Restore personal data after STACKI3-Space is working:

```bash
rsync -a --info=progress2 old:~/obsidian-vault/ ~/obsidian-vault/
rsync -a --info=progress2 old:~/git/ ~/git/
rsync -a --info=progress2 old:~/Documentos/ ~/Documentos/
```

Restore secrets manually. See `docs/migration-manifest.md`.

## 7. Final Checks

- `mod+Enter` opens a normal terminal.
- `mod+Shift+Enter` opens the main tmux terminal.
- `mod+p` opens SPACE search.
- `space doctor` passes or reports only known optional tools.
- `stack-theme apply deep-space` works.
- `stack-theme list` shows `montana` and the other shipped themes.
- `mod+p` → `system` → `themes` applies a theme without editing files by hand.
- Optional editor theme: `bash scripts/install-stackd-theme.sh` then pick **Stackd Montana** in Cursor/Kiro.
- `lazyjournal` opens from the terminal or from `space menu panels`.
- SSH to GitHub works.
