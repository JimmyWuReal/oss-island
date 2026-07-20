#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-release}"
ARCH="$(uname -m)"
VERSION="${VERSION:-0.1.0}"
BUILD_DIR="$ROOT/.build/$ARCH-apple-macosx/$CONFIGURATION"
APP_DIR="$ROOT/dist/Oss Island.app"
ICONSET="$ROOT/.build/AppIcon.iconset"

cd "$ROOT"
swift build -c "$CONFIGURATION" --product OssIsland
swift build -c "$CONFIGURATION" --product oss-island-event

rm -rf "$APP_DIR" "$ICONSET"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BUILD_DIR/OssIsland" "$APP_DIR/Contents/MacOS/OssIsland"
cp "$BUILD_DIR/oss-island-event" "$APP_DIR/Contents/Resources/oss-island-event"
cp "$ROOT/packaging/macos/Info.plist" "$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_DIR/Contents/Info.plist"

swift "$ROOT/scripts/generate-icon.swift" "$ICONSET"
iconutil -c icns "$ICONSET" -o "$APP_DIR/Contents/Resources/AppIcon.icns"

# Ad-hoc signing is local integrity metadata, not an Apple Developer ID signature.
codesign --force --deep --sign - "$APP_DIR"
codesign --verify --deep --strict "$APP_DIR"

echo "Built $APP_DIR"
