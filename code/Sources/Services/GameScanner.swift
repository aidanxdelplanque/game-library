import Foundation

struct ScannedGame: Identifiable {
    let id = UUID()
    var title: String
    var platform: Platform
    var launchType: Game.LaunchType
    var appPath: String
    var romPath: String?
    var emulatorArgs: [String]?
    var workingDirectory: String?
    var coverArtURL: String?
    var filePath: String  // the ROM/app file that was discovered

    func toGame() -> Game {
        Game(
            title: title,
            platform: platform,
            launchType: launchType,
            appPath: appPath,
            romPath: romPath,
            emulatorArgs: emulatorArgs,
            workingDirectory: workingDirectory,
            status: .untested,
            coverArtURL: coverArtURL
        )
    }
}

final class GameScanner {

    private let emulatorsRoot: String
    private let fm = FileManager.default

    /// Known cover art URLs keyed by lowercased title substring.
    private static let knownCoverArt: [String: String] = [
        "luigis mansion": "https://upload.wikimedia.org/wikipedia/en/5/5e/Lmbox.jpg",
        "luigi's mansion": "https://upload.wikimedia.org/wikipedia/en/5/5e/Lmbox.jpg",
        "need for speed": "https://upload.wikimedia.org/wikipedia/en/8/8e/Need_for_Speed_Most_Wanted_Box_Art.jpg",
        "sonic adventure 2": "https://upload.wikimedia.org/wikipedia/en/9/99/Sonic_Adventure_2_cover.png",
        "star fox adventures": "https://upload.wikimedia.org/wikipedia/en/3/31/Star_Fox_Adventures_GCN_Game_Box.jpg",
        "pikmin 2": "https://upload.wikimedia.org/wikipedia/en/3/38/Pikmin_2_Case.jpg",
        "pikmin": "https://upload.wikimedia.org/wikipedia/en/e/e4/Pikmin_cover_art.jpg",
    ]

    init(emulatorsRoot: String) {
        self.emulatorsRoot = emulatorsRoot
    }

    /// Look up a cover art URL by matching against known titles.
    func findCoverArt(for title: String) -> String? {
        let lower = title.lowercased()
        // Try longest match first for specificity (e.g. "pikmin 2" before "pikmin")
        let sorted = Self.knownCoverArt.keys.sorted { $0.count > $1.count }
        for key in sorted {
            if lower.contains(key) {
                return Self.knownCoverArt[key]
            }
        }
        return nil
    }

    /// ROM file extensions that we expect to find inside zip archives.
    private static let romExtensions: Set<String> = [
        "iso", "gcm", "wbfs", "wia", "rvz", "dol",  // GameCube/Wii
        "wux", "wud",                                  // Wii U
        "3ds", "cia", "cxi",                           // 3DS
        "z64", "n64", "v64",                           // N64
        "bin", "cue", "chd",                           // PS1/PS2
    ]

    /// Scan the emulators directory for games not already in the catalog.
    func scan(existingGames: [Game]) -> [ScannedGame] {
        let existingPaths = Set(
            existingGames.flatMap { game -> [String] in
                var paths = [game.appPath]
                if let rom = game.romPath { paths.append(rom) }
                return paths
            }
        )

        var discovered: [ScannedGame] = []

        discovered += scanDolphin(existingPaths: existingPaths)
        discovered += scanCemu(existingPaths: existingPaths)
        discovered += scanCitra(existingPaths: existingPaths)
        discovered += scanShadPS4(existingPaths: existingPaths)

        return discovered.sorted { $0.title < $1.title }
    }

    /// Extract all zip files among the scanned games. Returns updated games
    /// with romPath pointing to the extracted ROM file.
    func extractZips(_ games: [ScannedGame]) -> [ScannedGame] {
        return games.map { game in
            guard let romPath = game.romPath,
                  romPath.lowercased().hasSuffix(".zip") else {
                return game
            }

            if let extracted = extractZip(at: romPath) {
                var updated = game
                updated.romPath = extracted
                return updated
            }
            return game
        }
    }

    /// Extract a zip file in the same directory. Returns the path to the
    /// extracted ROM file, or nil on failure.
    private func extractZip(at zipPath: String) -> String? {
        let directory = (zipPath as NSString).deletingLastPathComponent

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", "-d", directory, zipPath]
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0 else { return nil }

        // Find the extracted ROM file
        guard let contents = try? fm.contentsOfDirectory(atPath: directory) else { return nil }

        for file in contents {
            let ext = (file as NSString).pathExtension.lowercased()
            if Self.romExtensions.contains(ext) {
                let fullPath = (directory as NSString).appendingPathComponent(file)
                // Make sure this isn't a file that existed before
                if fullPath != zipPath {
                    // Delete the zip now that we've extracted
                    try? fm.removeItem(atPath: zipPath)
                    return fullPath
                }
            }
        }

        return nil
    }

    // MARK: - Dolphin (GameCube / Wii)

    private func scanDolphin(existingPaths: Set<String>) -> [ScannedGame] {
        let dolphinDir = (emulatorsRoot as NSString).appendingPathComponent("Nintendo/dolphin")
        guard fm.fileExists(atPath: dolphinDir) else { return [] }

        let dolphinApp = findDolphinApp()
        let romExtensions: Set<String> = ["iso", "gcm", "wbfs", "wia", "rvz", "dol", "zip"]

        return scanDirectory(dolphinDir, extensions: romExtensions, existingPaths: existingPaths)
            .filter { !$0.hasSuffix(".dmg") }
            .map { path in
                let title = cleanTitle(from: path)
                let art = findCoverArt(for: title)
                if let app = dolphinApp {
                    return ScannedGame(
                        title: title,
                        platform: .gamecube,
                        launchType: .emulatorWithROM,
                        appPath: app,
                        romPath: path,
                        emulatorArgs: ["-e"],
                        coverArtURL: art,
                        filePath: path
                    )
                } else {
                    return ScannedGame(
                        title: title,
                        platform: .gamecube,
                        launchType: .emulatorWithROM,
                        appPath: "",
                        romPath: path,
                        coverArtURL: art,
                        filePath: path
                    )
                }
            }
    }

    private func findDolphinApp() -> String? {
        let candidates = [
            "/Applications/Dolphin.app",
            "/Applications/dolphin-emu.app",
            (emulatorsRoot as NSString).appendingPathComponent("Nintendo/dolphin/Dolphin.app")
        ]
        return candidates.first { fm.fileExists(atPath: $0) }
    }

    // MARK: - Cemu (Wii U)

    private func scanCemu(existingPaths: Set<String>) -> [ScannedGame] {
        let cemuDir = (emulatorsRoot as NSString).appendingPathComponent("Nintendo/Cemu")
        guard fm.fileExists(atPath: cemuDir) else { return [] }

        let cemuApp = "/Applications/Cemu.app"
        var results: [ScannedGame] = []

        // Scan for .wux/.wud files
        let wuxFiles = scanDirectory(cemuDir, extensions: ["wux", "wud"], existingPaths: existingPaths)
        for path in wuxFiles {
            let title = cleanTitle(from: path)
            results.append(ScannedGame(
                title: title,
                platform: .wiiU,
                launchType: .emulatorWithROM,
                appPath: cemuApp,
                romPath: path,
                emulatorArgs: ["-g"],
                coverArtURL: findCoverArt(for: title),
                filePath: path
            ))
        }

        // Scan for folder-format games (contain .app files + title ID in folder name)
        if let contents = try? fm.contentsOfDirectory(atPath: cemuDir) {
            for item in contents {
                let fullPath = (cemuDir as NSString).appendingPathComponent(item)
                var isDir: ObjCBool = false
                guard fm.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue else { continue }
                // Folder-format games have title IDs in brackets like [00050000101ebe00]
                guard item.contains("[Game]") || item.contains("[00050000") else { continue }
                guard !existingPaths.contains(fullPath) else { continue }
                // Check it has .app files inside
                let subfiles = (try? fm.contentsOfDirectory(atPath: fullPath)) ?? []
                let hasAppFiles = subfiles.contains { $0.hasSuffix(".app") && $0.first?.isNumber == true }
                guard hasAppFiles else { continue }

                let title = cleanCemuFolderTitle(item)
                results.append(ScannedGame(
                    title: title,
                    platform: .wiiU,
                    launchType: .emulatorWithROM,
                    appPath: cemuApp,
                    romPath: fullPath,
                    emulatorArgs: ["-g"],
                    coverArtURL: findCoverArt(for: title),
                    filePath: fullPath
                ))
            }
        }

        return results
    }

    // MARK: - Citra (3DS)

    private func scanCitra(existingPaths: Set<String>) -> [ScannedGame] {
        let citraDir = (emulatorsRoot as NSString).appendingPathComponent("Nintendo/citra")
        guard fm.fileExists(atPath: citraDir) else { return [] }

        let citraApp = (emulatorsRoot as NSString).appendingPathComponent(
            "Nintendo/citra/nightly/citra-qt.app"
        )
        let romExtensions: Set<String> = ["3ds", "cia", "cxi", "app"]

        return scanDirectory(citraDir, extensions: romExtensions, existingPaths: existingPaths)
            .map { path in
                let title = cleanTitle(from: path)
                return ScannedGame(
                    title: title,
                    platform: .threeDS,
                    launchType: .emulatorWithROM,
                    appPath: citraApp,
                    romPath: path,
                    coverArtURL: findCoverArt(for: title),
                    filePath: path
                )
            }
    }

    // MARK: - shadPS4

    private func scanShadPS4(existingPaths: Set<String>) -> [ScannedGame] {
        let gamesDir = (emulatorsRoot as NSString).appendingPathComponent("Playstation/PS4/Games")
        guard fm.fileExists(atPath: gamesDir) else { return [] }

        let ps4App = (emulatorsRoot as NSString).appendingPathComponent(
            "Playstation/PS4/shadPS4QtLauncher.app"
        )

        guard let contents = try? fm.contentsOfDirectory(atPath: gamesDir) else { return [] }

        return contents.compactMap { item -> ScannedGame? in
            let fullPath = (gamesDir as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue else { return nil }
            // shadPS4 game folders contain an eboot.bin
            let eboot = (fullPath as NSString).appendingPathComponent("eboot.bin")
            guard fm.fileExists(atPath: eboot) else { return nil }
            guard !existingPaths.contains(fullPath), !existingPaths.contains(eboot) else { return nil }

            return ScannedGame(
                title: item,
                platform: .ps4,
                launchType: .app,
                appPath: ps4App,
                filePath: fullPath
            )
        }
    }

    // MARK: - Helpers

    /// Recursively find files with given extensions, excluding already-known paths.
    private func scanDirectory(
        _ directory: String,
        extensions: Set<String>,
        existingPaths: Set<String>
    ) -> [String] {
        guard let enumerator = fm.enumerator(atPath: directory) else { return [] }

        var results: [String] = []
        while let relativePath = enumerator.nextObject() as? String {
            let fullPath = (directory as NSString).appendingPathComponent(relativePath)
            let ext = (relativePath as NSString).pathExtension.lowercased()
            guard extensions.contains(ext) else { continue }
            guard !existingPaths.contains(fullPath) else { continue }
            // Skip files inside .app bundles and build artifacts
            guard !relativePath.contains(".app/") else { continue }
            guard !relativePath.contains(".build/") else { continue }
            results.append(fullPath)
        }
        return results
    }

    /// Extract a clean game title from a ROM filename.
    /// "Luigis Mansion (USA).zip" → "Luigi's Mansion"
    func cleanTitle(from path: String) -> String {
        var name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension

        // Remove region/language tags in parentheses: (USA), (En,Fr,De), (Rev 2), etc.
        let parenRegex = try! NSRegularExpression(pattern: "\\s*\\([^)]*\\)")
        name = parenRegex.stringByReplacingMatches(
            in: name, range: NSRange(name.startIndex..., in: name), withTemplate: ""
        )

        // Remove bracket tags: [!], [Game], etc.
        let bracketRegex = try! NSRegularExpression(pattern: "\\s*\\[[^\\]]*\\]")
        name = bracketRegex.stringByReplacingMatches(
            in: name, range: NSRange(name.startIndex..., in: name), withTemplate: ""
        )

        return name.trimmingCharacters(in: .whitespaces)
    }

    /// Clean Cemu folder-format title.
    /// "PIKMIN 2 [Game] [00050000101ebe00]" → "Pikmin 2"
    private func cleanCemuFolderTitle(_ folderName: String) -> String {
        var name = folderName

        let bracketRegex = try! NSRegularExpression(pattern: "\\s*\\[[^\\]]*\\]")
        name = bracketRegex.stringByReplacingMatches(
            in: name, range: NSRange(name.startIndex..., in: name), withTemplate: ""
        )

        // Title-case if all caps
        name = name.trimmingCharacters(in: .whitespaces)
        if name == name.uppercased() && name.count > 3 {
            name = name.capitalized
        }

        return name
    }
}
