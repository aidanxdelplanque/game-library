import Foundation

final class AppSettings {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let emulatorsRoot = "emulatorsRoot"
        static let hasCompletedSetup = "hasCompletedSetup"
    }

    var emulatorsRoot: String? {
        get { defaults.string(forKey: Keys.emulatorsRoot) }
        set { defaults.set(newValue, forKey: Keys.emulatorsRoot) }
    }

    var hasCompletedSetup: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedSetup) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedSetup) }
    }
}
