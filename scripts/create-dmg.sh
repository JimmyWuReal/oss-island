#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-0.1.0}"
ARCH="$(uname -m)"
APP_DIR="$ROOT/dist/Oss Island.app"
STAGING="$ROOT/.build/dmg-staging"
DMG="$ROOT/dist/Oss-Island-$VERSION-$ARCH.dmg"

"$ROOT/scripts/build-app.sh"

rm -rf "$STAGING" "$DMG" "$DMG.sha256"
mkdir -p "$STAGING"
ditto "$APP_DIR" "$STAGING/Oss Island.app"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
    -volname "Oss Island" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$DMG"

DMG_NAME="$(basename "$DMG")"
(
    cd "$ROOT/dist"
    shasum -a 256 "$DMG_NAME" > "$DMG_NAME.sha256"
)
echo "Created $DMG"
