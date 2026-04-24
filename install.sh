#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

SCHEME="StickyBloom"
PROJECT="StickyBloom.xcodeproj"
CONFIG="Release"
DEST="/Applications/StickyBloom.app"

echo "Building $SCHEME ($CONFIG)..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" build >/dev/null

BUILT_PRODUCTS_DIR=$(
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" -showBuildSettings \
    | awk -F' = ' '/ BUILT_PRODUCTS_DIR =/ {print $2; exit}'
)

SOURCE_APP="$BUILT_PRODUCTS_DIR/StickyBloom.app"
if [[ ! -d "$SOURCE_APP" ]]; then
  echo "Error: built app not found at $SOURCE_APP" >&2
  exit 1
fi

if [[ -d "$DEST" ]]; then
  echo "Removing existing $DEST..."
  rm -rf "$DEST"
fi

echo "Copying to $DEST..."
cp -R "$SOURCE_APP" "$DEST"

echo "Installed: $DEST"
