import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ClipboardStore
    @State private var searchText = ""
    @State private var showAddCategory = false
    @State private var showSaveConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            categoryBar
            Divider()
            searchBar
            Divider()
            itemsList
        }
        .frame(width: 360)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
                .environmentObject(store)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Image(systemName: "clipboard")
                .foregroundStyle(.secondary)
            Text("Kopipes")
                .font(.headline)
            Spacer()
            // Save current clipboard button
            Button {
                store.saveCurrentClipboard()
                showSaveConfirm = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showSaveConfirm = false
                }
            } label: {
                Label(
                    showSaveConfirm ? "Saved!" : "Save Clipboard",
                    systemImage: showSaveConfirm ? "checkmark.circle.fill" : "plus.circle"
                )
                .font(.caption)
                .foregroundStyle(showSaveConfirm ? .green : .accentColor)
            }
            .buttonStyle(.plain)

            Button {
                showAddCategory = true
            } label: {
                Image(systemName: "folder.badge.plus")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("New category")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Category Bar

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                CategoryChip(
                    name: "All",
                    colorHex: "#5E81F4",
                    isSelected: store.selectedCategoryID == nil
                ) {
                    store.selectedCategoryID = nil
                }
                ForEach(store.categories) { cat in
                    CategoryChip(
                        name: cat.name,
                        colorHex: cat.colorHex,
                        isSelected: store.selectedCategoryID == cat.id
                    ) {
                        store.selectedCategoryID = cat.id
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteCategory(category: cat)
                        } label: {
                            Label("Delete \"\(cat.name)\"", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tertiary)
                .font(.caption)
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.callout)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
    }

    // MARK: - Items List

    private var visibleItems: [ClipboardItem] {
        let base = store.filteredItems
        guard !searchText.isEmpty else { return base }
        let q = searchText.lowercased()
        return base.filter {
            $0.content.lowercased().contains(q) || $0.label.lowercased().contains(q)
        }
    }

    private var itemsList: some View {
        Group {
            if visibleItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(visibleItems) { item in
                            ClipboardItemRow(item: item)
                                .environmentObject(store)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxHeight: 380)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text(searchText.isEmpty ? "No saved clips yet" : "No results")
                .foregroundStyle(.secondary)
                .font(.callout)
            if searchText.isEmpty {
                Text("Copy something, then tap \"Save Clipboard\"")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
