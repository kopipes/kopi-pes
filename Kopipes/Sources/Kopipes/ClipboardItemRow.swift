import SwiftUI

struct ClipboardItemRow: View {
    @EnvironmentObject var store: ClipboardStore
    let item: ClipboardItem
    @State private var isHovered = false
    @State private var showEditLabel = false
    @State private var showEditContent = false
    @State private var showAssignCategory = false
    @State private var showDeleteConfirm = false

    private var categoryColor: Color {
        guard let catID = item.categoryID,
              let cat = store.categories.first(where: { $0.id == catID }) else {
            return .clear
        }
        return Color(hex: cat.colorHex) ?? .accentColor
    }

    var body: some View {
        HStack(spacing: 8) {
            // Category color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(item.categoryID != nil ? categoryColor : Color.clear)
                .frame(width: 3)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.label)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Text(item.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            Spacer()

            if isHovered {
                actionButtons
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color(NSColor.selectedContentBackgroundColor).opacity(0.12) : .clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture {
            store.paste(item: item)
        }
        .contextMenu { contextMenu }
        .sheet(isPresented: $showEditLabel) {
            EditLabelView(item: item)
                .environmentObject(store)
        }
        .sheet(isPresented: $showEditContent) {
            EditContentView(item: item)
                .environmentObject(store)
        }
        .sheet(isPresented: $showAssignCategory) {
            AssignCategoryView(item: item)
                .environmentObject(store)
        }
        .alert("Delete Clip?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                store.delete(item: item)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(item.label)\"? This cannot be undone.")
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 4) {
            Button {
                showAssignCategory = true
            } label: {
                Image(systemName: "folder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Assign to category")

            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Delete")
        }
    }

    @ViewBuilder
    private var contextMenu: some View {
        Button {
            store.paste(item: item)
        } label: {
            Label("Paste", systemImage: "doc.on.clipboard")
        }
        Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item.content, forType: .string)
        } label: {
            Label("Copy to Clipboard", systemImage: "doc.on.doc")
        }
        Divider()
        Button {
            showEditLabel = true
        } label: {
            Label("Edit Label", systemImage: "pencil")
        }
        Button {
            showEditContent = true
        } label: {
            Label("Edit Content", systemImage: "text.cursor")
        }
        Button {
            showAssignCategory = true
        } label: {
            Label("Assign Category", systemImage: "folder")
        }
        Divider()
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
