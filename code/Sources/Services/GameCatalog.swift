import Foundation

final class GameCatalog {
    private(set) var games: [Game] = []
    private let filePath: String

    init(filePath: String) {
        self.filePath = filePath
    }

    func load() throws {
        let url = URL(fileURLWithPath: filePath)

        guard FileManager.default.fileExists(atPath: filePath) else {
            games = []
            return
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        games = try decoder.decode([Game].self, from: data)
    }

    func save() throws {
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
