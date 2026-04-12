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
    @Published var showingScanResults = false
    @Published var scannedGames: [ScannedGame] = []

    private let catalog = GameCatalog()
    private let launcher = GameLauncher()
    private let scanner = GameScanner()
    let coverArtService = CoverArtService()
    private var cancellables = Set<AnyCancellable>()

    init() {
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

        if !searchText.isEmpty {
            base = base.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func gameCount(for platform: Platform) -> Int {
        catalog.games(for: platform).count
    }

    func coverImage(for game: Game) -> NSImage? {
        coverArtService.cachedImage(for: game)
    }

    func loadCatalog() {
        try! catalog.load()
        games = catalog.games

        Task {
            await coverArtService.downloadAllCoverArt(for: games)
        }
    }

    func launch(game: Game) {
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

    func showInFinder(game: Game) {
        let url = URL(fileURLWithPath: game.appPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func copyPath(game: Game) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(game.appPath, forType: .string)
    }

    // MARK: - Scanning

    func scanForGames() {
        scannedGames = scanner.scan(existingGames: games)
        if scannedGames.isEmpty {
            launchError = "No new games found in /Users/aidan/Emulators/"
        } else {
            showingScanResults = true
        }
    }

    func findMissingArt() {
        var updated: [Game] = []
        for game in games where game.coverArtURL == nil {
            if let url = scanner.findCoverArt(for: game.title) {
                do {
                    try catalog.updateGame(id: game.id) { $0.coverArtURL = url }
                    updated.append(catalog.games.first { $0.id == game.id }!)
                } catch {}
            }
        }
        games = catalog.games

        if updated.isEmpty {
            launchError = "No cover art found for games missing artwork"
        } else {
            Task {
                await coverArtService.downloadAllCoverArt(for: updated)
            }
        }
    }

    func addScannedGames(_ toAdd: [ScannedGame]) {
        // Extract any zip files first
        let extracted = scanner.extractZips(toAdd)
        let newGames = extracted.map { $0.toGame() }
        do {
            try catalog.addGames(newGames)
            games = catalog.games
            showingScanResults = false

            Task {
                await coverArtService.downloadAllCoverArt(for: newGames)
            }
        } catch {
            launchError = "Failed to save catalog: \(error.localizedDescription)"
        }
    }
}
