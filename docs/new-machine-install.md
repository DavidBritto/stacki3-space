# New Machine Install

This is the clean path for rebuilding the workstation on another Linux Mint/X11 machine.

## 1. Install Linux Mint

Install Linux Mint normally, boot once into Cinnamon, connect to the network, and apply system updates:

```bash
sudo apt update && sudo apt upgrade
sudo apt install -y git curl rsync
```

## 2. Get STACKI3

Use the published bootstrap when the repo is public. This installs the APT dependency set and then deploys the STACKI3 config payload:

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/stacki3/main/install.sh | bash -s -- --deps
```

Use a fork or private repo by overriding the clone URL:

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/stacki3/main/install.sh \
  | STACKI3_REPO_URL=https://github.com/me/stacki3.git bash -s -- --deps
```

For an offline, unpublished, or SSH-only transfer, create the package on the source machine:

```bash
scripts/package.sh
scp dist/stacki3-package.tar.gz user@target:~/
```

Then on the target machine:

```bash
tar -xzf ~/stacki3-package.tar.gz
cd ~/stacki3-package
bash install.sh --deps
```

## 3. Review Dependencies Separately

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

## 4. Deploy Config Only

From the repo checkout:

```bash
bash install.sh
```

This mode deploys config only. It does not install desktop packages.

The installer keeps an existing `~/.zshrc` by default. On a clean machine where you want the packaged STACKI3 shell profile, use:

```bash
STACKI3_OVERWRITE_ZSHRC=1 bash install.sh
```

Log out and select the i3 session from LightDM. Then run:

```bash
space doctor
stack-theme current
scripts/verify-install.sh
```

## 5. Restore Daily Data

Restore personal data after STACKI3 is working:

```bash
rsync -a --info=progress2 old:~/obsidian-vault/ ~/obsidian-vault/
rsync -a --info=progress2 old:~/git/ ~/git/
rsync -a --info=progress2 old:~/Documentos/ ~/Documentos/
```

Restore secrets manually. See `docs/migration-manifest.md`.

## 6. Final Checks

- `mod+Enter` opens a normal terminal.
- `mod+Shift+Enter` opens the main tmux terminal.
- `mod+p` opens SPACE search.
- `space doctor` passes or reports only known optional tools.
- `stack-theme apply deep-space` works.
- `lazyjournal` opens from the terminal or from `space menu panels`.
- SSH to GitHub works.
