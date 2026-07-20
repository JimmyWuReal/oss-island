#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_SOURCE="$ROOT/dist/Oss Island.app"
APP_DEST="$HOME/Applications/Oss Island.app"
CLI_DEST="$HOME/.local/bin/oss-island-event"

"$ROOT/scripts/build-app.sh"

mkdir -p "$HOME/Applications" "$HOME/.local/bin"
rm -rf "$APP_DEST"
ditto "$APP_SOURCE" "$APP_DEST"
ln -sfn "$APP_DEST/Contents/Resources/oss-island-event" "$CLI_DEST"

echo "Installed Oss Island to $APP_DEST"
echo "Installed event CLI to $CLI_DEST"
echo "Add $HOME/.local/bin to PATH if it is not already present."
