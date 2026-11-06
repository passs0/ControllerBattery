#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: ./generate_icns.sh <source_image_1024x1024>"
    exit 1
fi

SRC="$1"
OUTPUT="${2:-AppIcon.icns}"
ICONSET="AppIcon.iconset"

echo "==> Creating iconset from $SRC..."
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

sips -s format png -z 16 16     "$SRC" --out "$ICONSET/icon_16x16.png" > /dev/null
sips -s format png -z 32 32     "$SRC" --out "$ICONSET/icon_16x16@2x.png" > /dev/null
sips -s format png -z 32 32     "$SRC" --out "$ICONSET/icon_32x32.png" > /dev/null
sips -s format png -z 64 64     "$SRC" --out "$ICONSET/icon_32x32@2x.png" > /dev/null
sips -s format png -z 128 128   "$SRC" --out "$ICONSET/icon_128x128.png" > /dev/null
sips -s format png -z 256 256   "$SRC" --out "$ICONSET/icon_128x128@2x.png" > /dev/null
sips -s format png -z 256 256   "$SRC" --out "$ICONSET/icon_256x256.png" > /dev/null
sips -s format png -z 512 512   "$SRC" --out "$ICONSET/icon_256x256@2x.png" > /dev/null
sips -s format png -z 512 512   "$SRC" --out "$ICONSET/icon_512x512.png" > /dev/null
sips -s format png -z 1024 1024 "$SRC" --out "$ICONSET/icon_512x512@2x.png" > /dev/null

echo "==> Compiling into $OUTPUT using iconutil..."
iconutil -c icns "$ICONSET" -o "$OUTPUT"
rm -rf "$ICONSET"

echo "==> Successfully generated $OUTPUT"
