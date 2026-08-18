# Kopipes

A lightweight macOS clipboard manager that lives in your menu bar. Save clips manually, organize them into categories, and paste them instantly with a single click.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- **Menu bar app** — no dock icon, always out of the way
- **Manual save** — saves only what you choose, not everything you copy
- **One-click paste** — click any saved clip to instantly paste it into the active app
- **Categories** — organize clips into color-coded categories
- **Search** — filter clips by label or content in real time
- **Edit labels** — rename any clip to something memorable
- **Persistent storage** — clips survive app restarts, stored locally in Application Support
- **Click-outside to close** — popover dismisses when you click anywhere else

---

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac
- Xcode 15+ (to build from source) — or use the prebuilt binary

---

## Building from Source

You do not need the full Xcode app. The Swift command-line tools are sufficient.

**1. Install Command Line Tools (if not already installed):**
```bash
xcode-select --install
```

**2. Clone the repo:**
```bash
git clone https://github.com/kopipes/kopi-pes.git
cd kopi-pes
```

**3. Build the `.app` bundle:**
```bash
mkdir -p build/Kopipes.app/Contents/MacOS
mkdir -p build/Kopipes.app/Contents/Resources

swiftc \
  Kopipes/Sources/Kopipes/Color+Hex.swift \
  Kopipes/Sources/Kopipes/Models.swift \
  Kopipes/Sources/Kopipes/PersistenceController.swift \
  Kopipes/Sources/Kopipes/ClipboardStore.swift \
  Kopipes/Sources/Kopipes/AppDelegate.swift \
  Kopipes/Sources/Kopipes/ClipboardItemRow.swift \
  Kopipes/Sources/Kopipes/SupportingViews.swift \
  Kopipes/Sources/Kopipes/ContentView.swift \
  Kopipes/Sources/Kopipes/KopipesApp.swift \
  -sdk $(xcrun --show-sdk-path --sdk macosx) \
  -target arm64-apple-macosx13.0 \
  -parse-as-library \
  -module-name Kopipes \
  -o build/Kopipes.app/Contents/MacOS/Kopipes

cp Kopipes/Resources/Info.plist build/Kopipes.app/Contents/Info.plist
printf 'APPL????' > build/Kopipes.app/Contents/PkgInfo
```

**4. Run it:**
```bash
xattr -cr build/Kopipes.app
open build/Kopipes.app
```

---

## Usage

### Saving a clip
1. Copy any text normally (`Cmd+C`)
2. Click the clipboard icon in the menu bar
3. Click **Save Clipboard** — the current clipboard content is saved

### Pasting a clip
1. Click the clipboard icon in the menu bar
2. Click any saved clip — it is copied to the clipboard and pasted into the previously active app automatically

> **Note:** On first use, macOS will ask for **Accessibility permission** to simulate the paste keystroke. Go to **System Settings → Privacy & Security → Accessibility** and enable Kopipes. Without it, clicking a clip still copies it to the clipboard but will not auto-paste.

### Categories
- Click the **folder+** icon in the header to create a category with a name and color
- Hover over any clip and click the **folder** icon to assign it to a category
- Click a category chip at the top to filter clips
- Right-click a category chip to delete it

### Other actions (right-click a clip)
| Action | Description |
|---|---|
| Paste | Copy + auto-paste into the active app |
| Copy to Clipboard | Copy without pasting |
| Edit Label | Rename the clip |
| Assign Category | Move to a category |
| Delete | Remove permanently |

---

## Project Structure

```
kopi-pes/
├── Kopipes/
│   ├── Sources/Kopipes/
│   │   ├── KopipesApp.swift          # @main entry point, menu bar only
│   │   ├── AppDelegate.swift         # NSStatusItem + NSPopover + event monitor
│   │   ├── Models.swift              # ClipboardItem, ClipCategory (Codable)
│   │   ├── ClipboardStore.swift      # @MainActor ObservableObject — all app logic
│   │   ├── PersistenceController.swift # JSON persistence in Application Support
│   │   ├── ContentView.swift         # Main popover UI
│   │   ├── ClipboardItemRow.swift    # Row with hover actions and context menu
│   │   ├── SupportingViews.swift     # Category chips, Add/Edit/Assign sheets
│   │   └── Color+Hex.swift           # Color initializer from hex string
│   └── Resources/
│       ├── Info.plist                # LSUIElement = true (no dock icon)
│       ├── Kopipes.entitlements      # Sandbox disabled (required for CGEvent paste)
│       └── Assets.xcassets/
└── Kopipes.xcodeproj/
```

---

## Data Storage

Clips and categories are stored as JSON at:

```
~/Library/Application Support/Kopipes/store.json
```

No data is sent anywhere. Everything stays on your machine.

---

## Permissions

| Permission | Why |
|---|---|
| Accessibility | To simulate `Cmd+V` and paste into other apps |

No network access, no sandboxing, no tracking.

---

## License

MIT — see [LICENSE](LICENSE)
