#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

SIGN_IDENTITY="Developer ID Application: RIJO GEORGE (K8383Q54VB)"
TEAM_ID="K8383Q54VB"

echo "==> Building Plain Paste..."
xcodebuild -project PlainPaste.xcodeproj \
    -scheme PlainPaste \
    -configuration Release \
    clean build \
    CONFIGURATION_BUILD_DIR="$SCRIPT_DIR/build_output" 2>&1

APP_DIR="$SCRIPT_DIR/build_output/Plain Paste.app"

echo "==> Code signing..."
codesign --force --options runtime --timestamp \
    --sign "$SIGN_IDENTITY" \
    "$APP_DIR"

echo "==> Verifying signature..."
codesign --verify --verbose "$APP_DIR"

echo ""
echo "Built and signed: $APP_DIR"
echo "Run with: open \"$APP_DIR\""
