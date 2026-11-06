#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "==> Building ControllerBattery (release)..."
swift build -c release

APP_NAME="ControllerBattery.app"
APP_DIR="$DIR/build/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "==> Packaging into $APP_NAME..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$DIR/.build/release/ControllerBattery" "$MACOS_DIR/ControllerBattery"
chmod +x "$MACOS_DIR/ControllerBattery"
cp "$DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

# If an AppIcon.icns exists in Resources or root, copy it
if [ -f "$DIR/AppIcon.icns" ]; then
    echo "==> Found AppIcon.icns, adding to bundle..."
    cp "$DIR/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

echo "==> Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_DIR"

echo "==> Successfully created $APP_DIR"
echo "==> To run: open \"$APP_DIR\""
