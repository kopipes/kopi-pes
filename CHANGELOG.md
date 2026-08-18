# Changelog

All notable changes to Kopipes are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-08-18

### Added
- Menu bar app with clipboard icon — no dock icon, runs as accessory app
- Manual save button — reads and saves the current system clipboard on demand
- Duplicate detection — identical clips are not saved twice
- One-click paste — clicking a clip copies it to the clipboard and simulates `Cmd+V` into the previously active app via `CGEvent`
- Click-outside-to-close — global event monitor dismisses the popover when clicking anywhere outside it
- Categories — create color-coded categories with a name and one of 8 preset colors
- Category filter chips — filter the clip list by category
- Assign category — assign or reassign any clip to a category via hover button or context menu
- Edit label — rename any clip to a custom short label
- Search — real-time search across clip labels and content
- Context menu on each row — paste, copy, edit label, assign category, delete
- JSON persistence — clips and categories stored in `~/Library/Application Support/Kopipes/store.json`
- Empty state — helpful prompt shown when no clips exist or search returns no results
- Built without sandbox — required for `CGEvent`-based paste to work across apps
- Builds with Swift Command Line Tools only — no full Xcode installation required
