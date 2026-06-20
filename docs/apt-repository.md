# APT Repository

STACKI3-Space can be distributed as a Debian package from GitHub Pages. The package updates the project files in `/usr/share/stacki3-space`; it does not modify user dotfiles during `apt upgrade`.

## User Install

Signed repository:

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

Temporary unsigned repository while the first signing key is not configured:

```bash
echo "deb [trusted=yes arch=amd64] https://davidbritto.github.io/stacki3-space stable main" \
  | sudo tee /etc/apt/sources.list.d/stacki3-space.list >/dev/null
sudo apt update
sudo apt install stacki3-space
stacki3-space apply --deps
```

## Update Flow

```bash
sudo apt update
sudo apt upgrade
stacki3-space apply
```

`sudo apt upgrade` only refreshes the packaged copy under `/usr/share/stacki3-space`. `stacki3-space apply` syncs that copy into the current user's `$HOME` with the existing backup behavior from `install.sh`.

## Maintainer Release Flow

1. Update `VERSION` and `debian/changelog` to the new version.
2. Commit the change and tag it, for example `v0.1.1`.
3. Push `main` and the tag to GitHub.
4. The `Build APT package` workflow validates scripts/tests, builds `stacki3-space_VERSION_all.deb`, attaches it to the tag release, and publishes the APT repository to GitHub Pages.
5. On your own notebook, run `sudo apt update && sudo apt upgrade`, then `stacki3-space apply` when you are ready to update your active config.

## Signing

The workflow signs the APT metadata when these repository secrets are present:

- `APT_GPG_PRIVATE_KEY`: armored private key used only by GitHub Actions.
- `APT_GPG_KEY_ID`: key id, fingerprint, or signing identity passed to `gpg --local-user`.

When both are configured, the Pages artifact includes:

- `stacki3-space-archive-keyring.asc`
- `dists/stable/InRelease`
- `dists/stable/Release.gpg`

Until then, the workflow still publishes an unsigned repo for early testing.

## Local Build

Install packaging tools:

```bash
sudo apt update
sudo apt install -y debhelper dpkg-dev
```

Build without installing:

```bash
dpkg-buildpackage -us -uc -b
```

Inspect the package:

```bash
dpkg-deb --info ../stacki3-space_*_all.deb
dpkg-deb --contents ../stacki3-space_*_all.deb
```
