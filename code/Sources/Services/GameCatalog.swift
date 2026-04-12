import Foundation

final class GameCatalog {
    private(set) var games: [Game] = []

    /// User-writable catalog path in Application Support.
    static var userCatalogPath: String {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!.appendingPathComponent("GameLibrary")
        try? FileManager.default.createDirectory(
            at: appSupport, withIntermediateDirectories: true
        )
        return appSupport.appendingPathComponent("games.json").path
    }

    func load() throws {
        let userPath = Self.userCatalogPath

        if FileManager.default.fileExists(atPath: userPath) {
            // Load from user catalog
            let data = try Data(contentsOf: URL(fileURLWithPath: userPath))
            games = try JSONDecoder().decode([Game].self, from: data)
        } else if let bundleURL = Bundle.module.url(forResource: "games", withExtension: "json") {
            // First launch: load from bundle and copy to user location
            let data = try Data(contentsOf: bundleURL)
            games = try JSONDecoder().decode([Game].self, from: data)
            try save()
        } else {
            games = []
        }
    }

    func save() throws {
        let url = URL(fileURLWithPath: Self.userCatalogPath)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(games)
        try data.write(to: url, options: .atomic)
    }

    func addGames(_ newGames: [Game]) throws {
        games.append(contentsOf: newGames)
        try save()
    }

    func updateGame(id: UUID, mutate: (inout Game) -> Void) throws {
        guard let idx = games.firstIndex(where: { $0.id == id }) else { return }
        mutate(&games[idx])
        try save()
    }

    func removeGame(id: UUID) throws {
        games.removeAll { $0.id == id }
        try save()
    }

    func games(for platform: Platform) -> [Game] {
        games.filter { $0.platform == platform }
    }
}
