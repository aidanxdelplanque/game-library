import Foundation

final class GameCatalog {
    private(set) var games: [Game] = []
    private let filePath: String?

    /// Load from a specific file path (for user-customized catalogs).
    init(filePath: String) {
        self.filePath = filePath
    }

    /// Load from the bundled games.json resource.
    init() {
        self.filePath = nil
    }

    func load() throws {
        let url: URL

        if let filePath = filePath {
            guard FileManager.default.fileExists(atPath: filePath) else {
                games = []
                return
            }
            url = URL(fileURLWithPath: filePath)
        } else {
            guard let bundleURL = Bundle.module.url(
                forResource: "games",
                withExtension: "json"
            ) else {
                games = []
                return
            }
            url = bundleURL
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        games = try decoder.decode([Game].self, from: data)
    }

    func save() throws {
        guard let filePath = filePath else {
            // Cannot save back to bundle resources — need a file path
            return
        }
        let url = URL(fileURLWithPath: filePath)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(games)
        try data.write(to: url, options: .atomic)
    }

    func games(for platform: Platform) -> [Game] {
        games.filter { $0.platform == platform }
    }
}
