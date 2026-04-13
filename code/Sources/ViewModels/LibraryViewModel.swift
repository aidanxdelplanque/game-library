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
    let coverArtService = CoverArtService()
    private var cancellables = Set<AnyCancellable>()

    private var scanner: GameScanner {
        GameScanner(emulatorsRoot: AppSettings.shared.emulatorsRoot ?? "")
    }

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
            launchError = "No new games found in \(AppSettings.shared.emulatorsRoot ?? "emulators folder")"
        } else {
            showingScanResults = true
        }
    }

    func findMissingArt() {
        // Find games that have no cached cover art on disk
        let missingArt = games.filter { coverArtService.coverArtPath(for: $0) == nil }

        if missingArt.isEmpty {
            launchError = "All games already have cover art"
            return
        }

        // Download art for games missing cached files — service tries libretro first, then coverArtURL
        Task {
            await coverArtService.downloadAllCoverArt(for: missingArt)
        }
    }

    func refreshAllArt() {
        Task {
            await coverArtService.refreshAllCoverArt(for: games)
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
