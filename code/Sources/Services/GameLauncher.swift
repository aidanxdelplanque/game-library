import Foundation
import AppKit

enum LaunchResult {
    case success
    case failure(String)
}

final class GameLauncher {

    func launch(_ game: Game) -> LaunchResult {
        guard !game.appPath.isEmpty else {
            return .failure("No app path configured for \(game.title)")
        }

        switch game.launchType {
        case .app:
            return launchApp(game)
        case .emulatorWithROM:
            return launchEmulatorWithROM(game)
        case .custom:
            return launchCustom(game)
        }
    }

    // MARK: - Launch Strategies

    /// Launch a .app bundle via `open` (same as double-clicking in Finder).
    private func launchApp(_ game: Game) -> LaunchResult {
        guard FileManager.default.fileExists(atPath: game.appPath) else {
            return .failure("App not found at: \(game.appPath)")
        }

        return runProcess(
            executablePath: "/usr/bin/open",
            arguments: [game.appPath],
            description: game.title
        )
    }

    /// Launch an emulator app with ROM path as an argument.
    /// Uses `open <app> --args <emulatorArgs> <romPath>`.
    private func launchEmulatorWithROM(_ game: Game) -> LaunchResult {
        guard let romPath = game.romPath else {
            return .failure("No ROM path specified for \(game.title)")
        }

        guard FileManager.default.fileExists(atPath: game.appPath) else {
            return .failure("Emulator not found at: \(game.appPath)")
        }

        guard FileManager.default.fileExists(atPath: romPath) else {
            return .failure("ROM not found at: \(romPath)")
        }

        var arguments = [game.appPath, "--args"]

        // Add emulator-specific arguments (e.g. "-g" for Cemu)
        if let args = game.emulatorArgs {
            arguments.append(contentsOf: args)
        }

        // Append the ROM path as the final argument
        arguments.append(romPath)

        return runProcess(
            executablePath: "/usr/bin/open",
            arguments: arguments,
            description: game.title
        )
    }

    /// Launch a custom executable directly with arguments.
    /// Used for OpenGOAL's `gk` binary and similar standalone executables.
    private func launchCustom(_ game: Game) -> LaunchResult {
        guard FileManager.default.fileExists(atPath: game.appPath) else {
            return .failure("Executable not found at: \(game.appPath)")
        }

        return runProcess(
            executablePath: game.appPath,
            arguments: game.emulatorArgs ?? [],
            workingDirectory: game.workingDirectory,
            description: game.title
        )
    }

    // MARK: - Helpers

    private func runProcess(
        executablePath: String,
        arguments: [String],
        workingDirectory: String? = nil,
        description: String
    ) -> LaunchResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        if let dir = workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: dir)
        }

        do {
            try process.run()
            return .success
        } catch {
            return .failure("Failed to launch \(description): \(error.localizedDescription)")
        }
    }
}
