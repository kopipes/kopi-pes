#!/bin/zsh
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_BUNDLE="$PROJECT_DIR/build/Kopipes.app"
APP_MACOS="$APP_BUNDLE/Contents/MacOS"
APP_RESOURCES="$APP_BUNDLE/Contents/Resources"
SDK=$(xcrun --show-sdk-path --sdk macosx)

echo "Building Kopipes..."

mkdir -p "$APP_MACOS" "$APP_RESOURCES"

swiftc \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/Color+Hex.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/Models.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/PersistenceController.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/ClipboardStore.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/AppDelegate.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/ClipboardItemRow.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/SupportingViews.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/ContentView.swift" \
  "$PROJECT_DIR/Kopipes/Sources/Kopipes/KopipesApp.swift" \
  -sdk "$SDK" \
  -target arm64-apple-macosx13.0 \
  -parse-as-library \
  -module-name Kopipes \
  -o "$APP_MACOS/Kopipes"

cp "$PROJECT_DIR/Kopipes/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
printf 'APPL????' > "$APP_BUNDLE/Contents/PkgInfo"

# Remove quarantine so macOS doesn't block it
xattr -cr "$APP_BUNDLE"

# Copy to /Applications so it's available from Finder and Spotlight
echo "Installing to /Applications..."
rm -rf /Applications/Kopipes.app
cp -r "$APP_BUNDLE" /Applications/Kopipes.app
xattr -cr /Applications/Kopipes.app

echo "Done. Kopipes is installed in /Applications."
echo "You can now open it from Finder, Launchpad, or Spotlight."
