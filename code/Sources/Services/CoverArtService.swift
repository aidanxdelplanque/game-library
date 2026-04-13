import Foundation
import AppKit

@MainActor
final class CoverArtService: ObservableObject {
    @Published private(set) var lastUpdated = Date()

    private let cacheDirectory: URL
    private let fileManager = FileManager.default

    // libretro-thumbnails repo names per platform
    private static let libretroPlatform: [Platform: String] = [
        .n64:      "Nintendo_-_Nintendo_64",
        .gamecube: "Nintendo_-_GameCube",
        .wiiU:     "Nintendo_-_Wii_U",
        .threeDS:  "Nintendo_-_Nintendo_3DS",
        .ps2:      "Sony_-_PlayStation_2",
        .ps4:      "Sony_-_PlayStation_4",
    ]

    // Manual art names for ports/custom launches that don't have ROM filenames.
    // Key is the game's catalog ID, value is the libretro Named_Boxarts filename (without .png).
    private static let manualArtNames: [String: (platform: String, name: String)] = [
        // SoH - OoT
        "A1B2C3D4-0001-0001-0001-000000000001": ("Nintendo_-_Nintendo_64", "Legend of Zelda, The - Ocarina of Time (USA) (Rev 2)"),
        // 2Ship - MM
        "A1B2C3D4-0001-0001-0001-000000000002": ("Nintendo_-_Nintendo_64", "Legend of Zelda, The - Majora's Mask (USA)"),
        // sm64ex
        "A1B2C3D4-0001-0001-0001-000000000003": ("Nintendo_-_Nintendo_64", "Super Mario 64 (USA)"),
        // OpenGOAL Jak 1
        "A1B2C3D4-0004-0001-0001-000000000001": ("Sony_-_PlayStation_2", "Jak and Daxter - The Precursor Legacy (USA) (En,Fr,De,Es,It)"),
        // OpenGOAL Jak 2
        "A1B2C3D4-0004-0001-0001-000000000002": ("Sony_-_PlayStation_2", "Jak II (USA) (En,Ja,Fr,De,Es,It,Ko) (v2.01)"),
        // OpenGOAL Jak 3
        "A1B2C3D4-0004-0001-0001-000000000003": ("Sony_-_PlayStation_2", "Jak 3 (USA) (En,Fr,De,Es,It,Pt,Ru)"),
        // Diablo / DevilutionX — no libretro entry, keep Wikipedia
        // Fallout CE — no libretro entry, keep Wikipedia
        // Fallout 2 CE — no libretro entry, keep Wikipedia
    ]

    init() {
        let home = fileManager.homeDirectoryForCurrentUser
        cacheDirectory = home
            .appendingPathComponent("Library/Caches/GameLibrary/covers", isDirectory: true)

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

    /// Build the libretro-thumbnails URL for a game.
    private func libretroURL(for game: Game) -> URL? {
        // Check manual mapping first (for ports)
        if let manual = Self.manualArtNames[game.id.uuidString] {
            let encoded = manual.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? manual.name
            return URL(string: "https://raw.githubusercontent.com/libretro-thumbnails/\(manual.platform)/master/Named_Boxarts/\(encoded).png")
        }

        // For emulator+ROM games, derive from ROM filename
        guard let repo = Self.libretroPlatform[game.platform] else { return nil }

        if let romPath = game.romPath {
            let romName = ((romPath as NSString).lastPathComponent as NSString).deletingPathExtension
            let encoded = romName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? romName
            return URL(string: "https://raw.githubusercontent.com/libretro-thumbnails/\(repo)/master/Named_Boxarts/\(encoded).png")
        }

        return nil
    }

    /// Downloads cover art for a game — tries libretro-thumbnails first, falls back to coverArtURL.
    func downloadCoverArt(for game: Game) async {
        let destination = cacheFilePath(for: game)
        if fileManager.fileExists(atPath: destination) { return }

        // Try libretro-thumbnails first
        if let url = libretroURL(for: game) {
            if await tryDownload(from: url, to: destination) { return }
        }

        // Fall back to the coverArtURL field (Wikipedia etc.)
        if let urlString = game.coverArtURL,
           let url = URL(string: urlString) {
            _ = await tryDownload(from: url, to: destination)
        }
    }

    /// Attempt to download an image from a URL. Returns true on success.
    private func tryDownload(from url: URL, to destination: String) async -> Bool {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return false
            }

            guard NSImage(data: data) != nil else { return false }

            try data.write(to: URL(fileURLWithPath: destination), options: .atomic)
            lastUpdated = Date()
            return true
        } catch {
            return false
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
        guard fileManager.fileExists(atPath: path) else { return nil }
        return NSImage(contentsOfFile: path)
    }

    /// Force re-download art for all games (clears cache first).
    func refreshAllCoverArt(for games: [Game]) async {
        // Clear existing cache
        if let files = try? fileManager.contentsOfDirectory(atPath: cacheDirectory.path) {
            for file in files {
                try? fileManager.removeItem(atPath: cacheDirectory.appendingPathComponent(file).path)
            }
        }
        lastUpdated = Date()
        await downloadAllCoverArt(for: games)
    }

    // MARK: - Private

    private func cacheFilePath(for game: Game) -> String {
        cacheDirectory.appendingPathComponent("\(game.id.uuidString).jpg").path
    }
}
