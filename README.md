# Kopipes

A lightweight macOS clipboard manager that lives in your menu bar. Save clips manually, organize them into categories, and paste them instantly with a single click.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Release](https://img.shields.io/github/v/release/kopipes/kopi-pes)

---

## Download

**[Download Kopipes-v1.0.0.zip](https://github.com/kopipes/kopi-pes/releases/latest/download/Kopipes-v1.0.0.zip)**

Prebuilt for Apple Silicon (arm64), macOS 13+.

### Install from the prebuilt binary

**1. Download and unzip** `Kopipes-v1.0.0.zip`

**2. Move to Applications:**
```bash
mv ~/Downloads/Kopipes.app /Applications/Kopipes.app
```

**3. Clear Gatekeeper quarantine and sign (required on macOS 14+):**
```bash
sudo xattr -cr /Applications/Kopipes.app
sudo codesign --sign - --force --deep /Applications/Kopipes.app
```

**4. Open from Finder, Launchpad, or Spotlight.**

> macOS will ask for **Accessibility permission** on first paste. Go to **System Settings → Privacy & Security → Accessibility** and enable Kopipes.

---

## Features

- **Menu bar app** — no dock icon, always out of the way
- **Manual save** — saves only what you choose, not everything you copy
- **One-click paste** — click any saved clip to instantly paste it into the active app
- **Categories** — organize clips into color-coded categories
- **Search** — filter clips by label or content in real time
- **Edit labels and content** — rename or rewrite any saved clip
- **Delete confirmation** — confirms before removing a clip permanently
- **Persistent storage** — clips survive app restarts, stored locally in Application Support
- **Click-outside to close** — popover dismisses when you click anywhere else
- **Quit button** — power icon in the header closes the app

---

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (arm64) for the prebuilt binary
- Swift Command Line Tools (to build from source — no full Xcode needed)

---

## Building from Source

**1. Install Command Line Tools (if not already installed):**
```bash
xcode-select --install
```

**2. Clone the repo:**
```bash
git clone https://github.com/kopipes/kopi-pes.git
cd kopi-pes
```

**3. Build, sign, and install in one step:**
```bash
chmod +x build.sh
./build.sh
```

This compiles the app, ad-hoc signs it, clears quarantine, and installs it to `/Applications` automatically.

> After installing, run the Gatekeeper step from the **Install** section above if macOS still blocks the app.

---

## Usage

### Saving a clip
1. Copy any text normally (`Cmd+C`)
2. Click the clipboard icon in the menu bar
3. Click **Save Clipboard** — the current clipboard content is saved

### Pasting a clip
1. Click the clipboard icon in the menu bar
2. Click any saved clip — it is copied to the clipboard and pasted into the previously active app automatically

> **Accessibility permission** is required for auto-paste. macOS prompts on first use. Without it, clicking a clip copies to clipboard but does not auto-paste.

### Categories
- Click the **folder+** icon in the header to create a category with a name and color
- Hover over any clip and click the **folder** icon to assign it to a category
- Click a category chip at the top to filter clips
- Right-click a category chip to delete it

### Clip actions (right-click any clip)
| Action | Description |
|---|---|
| Paste | Copy + auto-paste into the active app |
| Copy to Clipboard | Copy without pasting |
| Edit Label | Rename the clip |
| Edit Content | Edit the full text content |
| Assign Category | Move to a category |
| Delete | Asks for confirmation, then removes |

### Closing the app
Click the **power icon** in the top-right corner of the popover.

---

## Project Structure

```
kopi-pes/
├── build.sh                          # One-step build + sign + install script
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

