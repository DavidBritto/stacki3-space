# Package Verification

Use these commands before publishing a release or after changing Debian packaging.

## Static Checks

```bash
bash -n install.sh
find scripts payload -type f -name '*.sh' -exec bash -n {} +
bash -n bin/stacki3-space
python3 -m py_compile \
  payload/.config/polybar/scripts/spotify_tui.py \
  payload/.config/i3/spotify_workspace_name.py
python3 -m unittest discover -s tests
```

## Build the Debian Package

```bash
sudo apt update
sudo apt install -y debhelper dpkg-dev
dpkg-buildpackage -us -uc -b
```

Expected output:

```text
../stacki3-space_VERSION_all.deb
```

## Inspect Without Installing

```bash
dpkg-deb --info ../stacki3-space_*_all.deb
dpkg-deb --contents ../stacki3-space_*_all.deb | grep -E '/usr/(bin/stacki3-space|share/stacki3-space/)'
```

The package should contain `/usr/bin/stacki3-space` and the payload under `/usr/share/stacki3-space/`.

## Local Wrapper Smoke Test

Run the wrapper against the source checkout without installing the package:

```bash
STACKI3_SPACE_ROOT="$PWD" bash bin/stacki3-space version
STACKI3_SPACE_ROOT="$PWD" bash bin/stacki3-space deps
```

Do not run `stacki3-space apply` from this smoke test unless you want to sync the current checkout into your active `$HOME`.

## Controlled Install Test

Use a VM, test user, or disposable Mint/X11 session:

```bash
sudo apt install ./../stacki3-space_*_all.deb
stacki3-space path
stacki3-space version
stacki3-space apply
stacki3-space doctor
```

Confirm that `sudo apt install` itself does not change user dotfiles. The `$HOME` sync should happen only after `stacki3-space apply`.
