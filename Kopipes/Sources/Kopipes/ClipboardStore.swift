import Foundation
import AppKit

/// Central store — owns all data and drives persistence.
/// All mutations must happen on the main actor.
@MainActor
final class ClipboardStore: ObservableObject {
    static let shared = ClipboardStore()

    @Published var items: [ClipboardItem] = []
    @Published var categories: [ClipCategory] = []
    @Published var selectedCategoryID: UUID? = nil  // nil = "All"

    private let persistence = PersistenceController()

    private init() {
        load()
    }

    // MARK: - Derived

    var filteredItems: [ClipboardItem] {
        guard let catID = selectedCategoryID else { return items }
        return items.filter { $0.categoryID == catID }
    }

    // MARK: - Clipboard Actions

    /// Reads the current system clipboard and saves it as a new item.
    func saveCurrentClipboard(categoryID: UUID? = nil) {
        guard let text = NSPasteboard.general.string(forType: .string),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Avoid exact duplicates
        if items.contains(where: { $0.content == text }) { return }

        let item = ClipboardItem(content: text, categoryID: categoryID ?? selectedCategoryID)
        items.insert(item, at: 0)
        save()
    }

    /// Copies the item back to the clipboard and triggers a paste.
    func paste(item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)

        // Close the popover first, then send Cmd+V to the previously active app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.simulatePaste()
        }
    }

    private func simulatePaste() {
        // Synthesise Cmd+V via CGEvent
        let src = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true) // V key
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        let loc = CGEventTapLocation.cghidEventTap
        keyDown?.post(tap: loc)
        keyUp?.post(tap: loc)
    }

    // MARK: - Item Management

    func delete(item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func update(item: ClipboardItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    // MARK: - Category Management

    func addCategory(name: String, colorHex: String = "#5E81F4") {
        let cat = ClipCategory(name: name, colorHex: colorHex)
        categories.append(cat)
        save()
    }

    func deleteCategory(category: ClipCategory) {
        // Unassign items that belonged to this category
        for i in items.indices where items[i].categoryID == category.id {
            items[i].categoryID = nil
        }
        categories.removeAll { $0.id == category.id }
        if selectedCategoryID == category.id { selectedCategoryID = nil }
        save()
    }

    func updateCategory(category: ClipCategory) {
        if let idx = categories.firstIndex(where: { $0.id == category.id }) {
            categories[idx] = category
            save()
        }
    }

    // MARK: - Persistence

    private func load() {
        let data = persistence.load()
        items = data.items
        categories = data.categories
    }

    private func save() {
        persistence.save(items: items, categories: categories)
    }
}
