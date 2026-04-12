import Foundation

enum Platform: String, Codable, CaseIterable, Identifiable {
    case n64
    case wiiU
    case threeDS
    case ps2
    case ps4
    case pc

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .n64:     return "Nintendo 64"
        case .wiiU:    return "Wii U"
        case .threeDS: return "Nintendo 3DS"
        case .ps2:     return "PlayStation 2"
        case .ps4:     return "PlayStation 4"
        case .pc:      return "PC"
        }
    }

    var shortName: String {
        switch self {
        case .n64:     return "N64"
        case .wiiU:    return "Wii U"
        case .threeDS: return "3DS"
        case .ps2:     return "PS2"
        case .ps4:     return "PS4"
        case .pc:      return "PC"
        }
    }

    var sfSymbolName: String {
        switch self {
        case .n64:     return "gamecontroller"
        case .wiiU:    return "gamecontroller.fill"
        case .threeDS: return "rectangle.portrait.on.rectangle.portrait"
        case .ps2:     return "playstation.logo"
        case .ps4:     return "playstation.logo"
        case .pc:      return "desktopcomputer"
        }
    }

    var colorHex: String {
        switch self {
        case .n64:     return "#E60012"
        case .wiiU:    return "#00A4E4"
        case .threeDS: return "#D12228"
        case .ps2:     return "#003087"
        case .ps4:     return "#00439C"
        case .pc:      return "#6B7280"
        }
    }

    var sortOrder: Int {
        switch self {
        case .n64:     return 0
        case .wiiU:    return 1
        case .threeDS: return 2
        case .ps2:     return 3
        case .ps4:     return 4
        case .pc:      return 5
        }
    }
}
