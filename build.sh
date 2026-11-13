#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "==> Building LifeBar (release)..."
swift build -c release

APP_NAME="LifeBar.app"
APP_DIR="$DIR/build/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "==> Packaging into $APP_NAME..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$DIR/.build/release/LifeBar" "$MACOS_DIR/LifeBar"
chmod +x "$MACOS_DIR/LifeBar"
cp "$DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

if [ -d "$DIR/assets/LifeBar.icon.xcassets" ]; then
    if xcrun --find actool >/dev/null 2>&1; then
        echo "==> Compiling the Light, Dark, Clear, and Tinted app icon variants..."
        PARTIAL_PLIST="$(mktemp "$APP_DIR/icon-partial.XXXXXX")"
        xcrun actool "$DIR/assets/LifeBar.icon.xcassets" \
            --compile "$RESOURCES_DIR" \
            --platform macosx \
            --minimum-deployment-target 13.0 \
            --app-icon LifeBar \
            --output-partial-info-plist "$PARTIAL_PLIST" \
            --output-format human-readable-text
        python3 - "$PARTIAL_PLIST" "$CONTENTS_DIR/Info.plist" <<'PY'
import plistlib, sys
with open(sys.argv[1], "rb") as f:
    additions = plistlib.load(f)
with open(sys.argv[2], "rb") as f:
    info = plistlib.load(f)
info.update(additions)
with open(sys.argv[2], "wb") as f:
    plistlib.dump(info, f)
PY
        rm -f "$PARTIAL_PLIST"
    elif [ "${CI:-}" = "true" ]; then
        echo "Error: Xcode with actool is required to build the dynamic app icon." >&2
        exit 1
    else
        echo "Warning: actool is unavailable; using the legacy static icon for this local build." >&2
    fi
fi

# Prefer actool's compact ICNS fallback while keeping all four appearances in
# Assets.car. Copy the larger static icon only when this machine lacks actool.
if [ ! -f "$RESOURCES_DIR/LifeBar.icns" ] && [ -f "$DIR/AppIcon.icns" ]; then
    cp "$DIR/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

echo "==> Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_DIR"

echo "==> Successfully created $APP_DIR"
echo "==> To run: open \"$APP_DIR\""
