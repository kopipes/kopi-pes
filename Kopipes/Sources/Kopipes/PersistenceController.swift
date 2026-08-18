import Foundation

/// Simple JSON-backed persistence stored in Application Support.
struct StoreData: Codable {
    var items: [ClipboardItem]
    var categories: [ClipCategory]
}

final class PersistenceController {
    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Kopipes", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("store.json")
    }

    func load() -> StoreData {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(StoreData.self, from: data) else {
            return StoreData(items: [], categories: [])
        }
        return decoded
    }

    func save(items: [ClipboardItem], categories: [ClipCategory]) {
        let data = StoreData(items: items, categories: categories)
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: fileURL, options: .atomic)
    }
}
