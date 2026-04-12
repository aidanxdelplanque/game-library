import Foundation
import AppKit

@MainActor
final class CoverArtService: ObservableObject {
    @Published private(set) var lastUpdated = Date()

    private let cacheDirectory: URL
    private let fileManager = FileManager.default

    init() {
        let home = fileManager.homeDirectoryForCurrentUser
        cacheDirectory = home
            .appendingPathComponent("Library/Caches/GameLibrary/covers", isDirectory: true)

        // Create the cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true
            )
        }
    }

    /// Returns the local cached file path if cover art has been downloaded for this game.
    func coverArtPath(for game: Game) -> String? {
        let path = cacheFilePath(for: game)
        return fileManager.fileExists(atPath: path) ? path : nil
    }

    /// Downloads cover art from the game's coverArtURL and saves it to the cache.
    func downloadCoverArt(for game: Game) async {
        guard let urlString = game.coverArtURL,
              let url = URL(string: urlString) else {
            return
        }

        // Skip if already cached
        let destination = cacheFilePath(for: game)
        if fileManager.fileExists(atPath: destination) {
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Verify we got a successful HTTP response
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return
            }

            // Verify the data is a valid image
            guard NSImage(data: data) != nil else {
                return
            }

            try data.write(to: URL(fileURLWithPath: destination), options: .atomic)

            // Notify observers that cached images changed
            lastUpdated = Date()
        } catch {
            // Download failed — skip silently
        }
    }

    /// Downloads cover art for all games concurrently.
    func downloadAllCoverArt(for games: [Game]) async {
        await withTaskGroup(of: Void.self) { group in
            for game in games {
                group.addTask {
                    await self.downloadCoverArt(for: game)
                }
            }
        }
    }

    /// Loads the cached cover art image from disk, if it exists.
    func cachedImage(for game: Game) -> NSImage? {
        let path = cacheFilePath(for: game)
        guard fileManager.fileExists(atPath: path) else {
            return nil
        }
        return NSImage(contentsOfFile: path)
    }

    // MARK: - Private

    private func cacheFilePath(for game: Game) -> String {
        cacheDirectory.appendingPathComponent("\(game.id.uuidString).jpg").path
    }
}
