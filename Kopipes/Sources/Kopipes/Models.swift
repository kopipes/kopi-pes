import Foundation
import AppKit

/// A single saved clipboard entry
struct ClipboardItem: Identifiable, Codable, Equatable {
    var id: UUID
    var content: String
    var categoryID: UUID?
    var createdAt: Date
    var label: String  // user-defined short label, defaults to truncated content

    init(id: UUID = UUID(), content: String, categoryID: UUID? = nil, label: String? = nil) {
        self.id = id
        self.content = content
        self.categoryID = categoryID
        self.createdAt = Date()
        self.label = label ?? String(content.prefix(40)).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// A user-defined category to group clipboard items
struct ClipCategory: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var colorHex: String  // e.g. "#FF6B6B"

    init(id: UUID = UUID(), name: String, colorHex: String = "#5E81F4") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}
