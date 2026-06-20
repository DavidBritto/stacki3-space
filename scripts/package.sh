#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/dist"
ARCHIVE="$DIST/stacki3-package.tar.gz"
PACKAGE_ROOT="$DIST/stacki3-package"

mkdir -p "$DIST"
rm -rf "$PACKAGE_ROOT" "$ARCHIVE"
mkdir -p "$PACKAGE_ROOT"

cp -a \
  "$ROOT/install.sh" \
  "$ROOT/README.md" \
  "$ROOT/stack.md" \
  "$PACKAGE_ROOT/"

cp -a \
  "$ROOT/docs" \
  "$ROOT/scripts" \
  "$ROOT/payload" \
  "$PACKAGE_ROOT/"

find "$PACKAGE_ROOT" -type d -name '__pycache__' -prune -exec rm -rf {} +
find "$PACKAGE_ROOT" -type f -name '*.pyc' -delete

tar -C "$DIST" -czf "$ARCHIVE" stacki3-package
rm -rf "$PACKAGE_ROOT"

printf '[stacki3-package] wrote %s\n' "$ARCHIVE"
