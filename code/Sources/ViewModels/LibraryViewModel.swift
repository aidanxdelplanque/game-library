import SwiftUI
import AppKit
import Combine

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var games: [Game] = []
    @Published var selectedPlatform: Platform?
    @Published var searchText: String = ""
    @Published var launchError: String?
    @Published var launchingGameID: UUID?

    private let catalog = GameCatalog()
    private let launcher = GameLauncher()
    let coverArtService = CoverArtService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Forward cover art service changes so the UI refreshes when images download
        coverArtService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var filteredGames: [Game] {
        var base: [Game]
        if let platform = selectedPlatform {
            base = catalog.games(for: platform)
        } else {
            base = games
        }

        // Apply search filter
        if !searchText.isEmpty {
            base = base.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    /// Number of games for a specific platform.
    func gameCount(for platform: Platform) -> Int {
        catalog.games(for: platform).count
    }

    /// Returns the cached cover art image for a game, if available.
    func coverImage(for game: Game) -> NSImage? {
        coverArtService.cachedImage(for: game)
    }

    func loadCatalog() {
        try! catalog.load()
        games = catalog.games

        // Kick off cover art downloads in the background
        Task {
            await coverArtService.downloadAllCoverArt(for: games)
        }
    }

    func launch(game: Game) {
        // Brief launch animation flash
        launchingGameID = game.id
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            launchingGameID = nil
        }

        let result = launcher.launch(game)
        switch result {
        case .success:
            launchError = nil
        case .failure(let message):
            launchError = message
        }
    }

    /// Reveals a game's app path in Finder.
    func showInFinder(game: Game) {
        let url = URL(fileURLWithPath: game.appPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Copies a game's app path to the clipboard.
    func copyPath(game: Game) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(game.appPath, forType: .string)
    }
}
