import Foundation

struct Game: Codable, Identifiable {
    let id: UUID
    var title: String
    var platform: Platform
    var launchType: LaunchType
    var appPath: String
    var romPath: String?
    var emulatorArgs: [String]?
    var workingDirectory: String?
    var status: Status
    var coverArtURL: String?
    var coverArtLocalPath: String?

    enum LaunchType: String, Codable {
        case app
        case emulatorWithROM
        case custom
    }

    enum Status: String, Codable {
        case working
        case untested
        case broken
    }

    init(
        id: UUID = UUID(),
        title: String,
        platform: Platform,
        launchType: LaunchType,
        appPath: String,
        romPath: String? = nil,
        emulatorArgs: [String]? = nil,
        workingDirectory: String? = nil,
        status: Status = .untested,
        coverArtURL: String? = nil,
        coverArtLocalPath: String? = nil
    ) {
        self.id = id
        self.title = title
        self.platform = platform
        self.launchType = launchType
        self.appPath = appPath
        self.romPath = romPath
        self.emulatorArgs = emulatorArgs
        self.workingDirectory = workingDirectory
        self.status = status
        self.coverArtURL = coverArtURL
        self.coverArtLocalPath = coverArtLocalPath
    }
}
