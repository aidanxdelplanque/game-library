import Foundation

struct EmulatorShortcut {
    let name: String
    let appPath: String

    private static let all: [EmulatorShortcut] = [
        EmulatorShortcut(name: "Parallel Launcher (N64)", appPath: "/Applications/parallel-launcher.app"),
        EmulatorShortcut(name: "Dolphin (GameCube)", appPath: "/Applications/Dolphin.app"),
        EmulatorShortcut(name: "Cemu (Wii U)", appPath: "/Applications/Cemu.app"),
        EmulatorShortcut(name: "Citra (3DS)", appPath: "/Users/aidan/Emulators/Nintendo/citra/nightly/citra-qt.app"),
        EmulatorShortcut(name: "PCSX2 (PS2)", appPath: "/Applications/PCSX2.app"),
        EmulatorShortcut(name: "shadPS4 (PS4)", appPath: "/Users/aidan/Emulators/Playstation/PS4/shadPS4QtLauncher.app"),
    ]

    /// Only show emulators that are actually installed.
    static var available: [EmulatorShortcut] {
        all.filter { FileManager.default.fileExists(atPath: $0.appPath) }
    }

    func launch() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [appPath]
        try? process.run()
    }
}
