import SwiftUI

// MARK: - About Sheet

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Icon + name
            VStack(spacing: 8) {
                Image(systemName: "clipboard.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)

                Text("Kopipes")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Description
            Text("A lightweight macOS clipboard manager that lives in your menu bar. Save clips manually, organize them into categories, and paste them instantly with a single click.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            // Details
            VStack(spacing: 6) {
                infoRow(label: "Developer", value: "Kopipes")
                infoRow(label: "License", value: "MIT")
                infoRow(label: "Platform", value: "macOS 13.0+")
                infoRow(label: "Storage", value: "Local — no cloud, no tracking")
                infoRow(label: "Source", value: "github.com/kopipes/kopi-pes")
            }

            Divider()

            Button("Close") { dismiss() }
                .keyboardShortcut(.defaultAction)
        }
        .padding(24)
        .frame(width: 320)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .trailing)
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let name: String
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(hex: colorHex) ?? .accentColor)
                    .frame(width: 7, height: 7)
                Text(name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isSelected
                          ? (Color(hex: colorHex) ?? .accentColor).opacity(0.18)
                          : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? (Color(hex: colorHex) ?? .accentColor) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Category Sheet

struct AddCategoryView: View {
    @EnvironmentObject var store: ClipboardStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "#5E81F4"

    private let presetColors = [
        "#5E81F4", "#FF6B6B", "#4ECDC4", "#FFE66D",
        "#A8E6CF", "#FF8B94", "#B4A7D6", "#F9C784"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Category")
                .font(.headline)

            TextField("Category name", text: $name)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(presetColors, id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex) ?? .accentColor)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: selectedColor == hex ? 2 : 0)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 1)
                            .onTapGesture { selectedColor = hex }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") {
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    store.addCategory(name: trimmed, colorHex: selectedColor)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 300)
    }
}

// MARK: - Edit Content Sheet

struct EditContentView: View {
    @EnvironmentObject var store: ClipboardStore
    @Environment(\.dismiss) private var dismiss
    let item: ClipboardItem
    @State private var content: String

    init(item: ClipboardItem) {
        self.item = item
        _content = State(initialValue: item.content)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Content")
                .font(.headline)

            TextEditor(text: $content)
                .font(.callout)
                .frame(minHeight: 120, maxHeight: 200)
                .padding(6)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(NSColor.separatorColor), lineWidth: 1)
                )

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    var updated = item
                    updated.content = trimmed
                    // Update label too if it was auto-generated from the old content
                    if item.label == String(item.content.prefix(40)).trimmingCharacters(in: .whitespacesAndNewlines) {
                        updated.label = String(trimmed.prefix(40)).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    store.update(item: updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}

// MARK: - Edit Label Sheet

struct EditLabelView: View {
    @EnvironmentObject var store: ClipboardStore
    @Environment(\.dismiss) private var dismiss
    let item: ClipboardItem
    @State private var label: String

    init(item: ClipboardItem) {
        self.item = item
        _label = State(initialValue: item.label)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Label")
                .font(.headline)

            TextField("Label", text: $label)
                .textFieldStyle(.roundedBorder)

            Text("Content preview:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(item.content)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(4)
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    var updated = item
                    updated.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.update(item: updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 300)
    }
}

// MARK: - Assign Category Sheet

struct AssignCategoryView: View {
    @EnvironmentObject var store: ClipboardStore
    @Environment(\.dismiss) private var dismiss
    let item: ClipboardItem
    @State private var selectedID: UUID?

    init(item: ClipboardItem) {
        self.item = item
        _selectedID = State(initialValue: item.categoryID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Assign Category")
                .font(.headline)

            if store.categories.isEmpty {
                Text("No categories yet. Create one first.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                VStack(spacing: 4) {
                    // "None" option
                    categoryRow(id: nil, name: "None", colorHex: "#AAAAAA")
                    Divider()
                    ForEach(store.categories) { cat in
                        categoryRow(id: cat.id, name: cat.name, colorHex: cat.colorHex)
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Assign") {
                    var updated = item
                    updated.categoryID = selectedID
                    store.update(item: updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(store.categories.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 260)
    }

    private func categoryRow(id: UUID?, name: String, colorHex: String) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: colorHex) ?? .gray)
                .frame(width: 10, height: 10)
            Text(name)
                .font(.callout)
            Spacer()
            if selectedID == id {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedID = id }
        .padding(.vertical, 4)
    }
}
