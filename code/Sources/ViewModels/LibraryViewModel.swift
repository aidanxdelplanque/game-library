import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var games: [Game] = []
    @Published var selectedPlatform: Platform?
    @Published var launchError: String?

    private let catalog = GameCatalog()
    private let launcher = GameLauncher()

    var filteredGames: [Game] {
        let base: [Game]
        if let platform = selectedPlatform {
            base = catalog.games(for: platform)
        } else {
            base = games
        }
        return base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    /// Number of games for a specific platform.
    func gameCount(for platform: Platform) -> Int {
        catalog.games(for: platform).count
    }

    func loadCatalog() {
        try! catalog.load()
        games = catalog.games
    }

    func launch(game: Game) {
        let result = launcher.launch(game)
        switch result {
        case .success:
            launchError = nil
        case .failure(let message):
            launchError = message
        }
    }
}
