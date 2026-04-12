# Game Library

## Project Overview
A native SwiftUI macOS app that serves as a unified game launcher. Replaces
a dock full of emulators and PC ports with one clean grid of cover art,
organized by system. Click a game, it launches. The app never touches
emulator settings, controller configs, or save data — it's a thin launcher.

## Project Layout
```
/Users/aidan/projects/game-library/
├── PLAN.md           ← master plan with game inventory, tasks, status
├── CLAUDE.md         ← this file
├── SESSION.md        ← cross-session handoff log
└── code/
    ├── Package.swift
    └── Sources/
        ├── GameLibraryApp.swift
        ├── Models/       ← Game, Platform (Codable, SwiftUI-independent)
        ├── Services/     ← GameCatalog, GameLauncher, CoverArtService
        ├── Views/        ← SwiftUI views
        └── Resources/    ← games.json catalog
```

## Development
### Build & Run
```bash
cd /Users/aidan/projects/game-library/code
swift build
swift run GameLibrary
```

### Release Build (.app bundle)
```bash
swift build -c release
# Build script TBD for .app bundle creation
```

### Test
```bash
swift test
```

## Conventions
- Swift 5.9+, SwiftUI, macOS 14+ (Sonoma)
- MVVM: Models and Services are plain Swift (no SwiftUI imports) so they
  can be extracted into a server later
- Game catalog is a JSON file — the source of truth for all games and
  launch commands
- Cover art cached in ~/Library/Caches/GameLibrary/
- User data (favorites, recents) in ~/Library/Application Support/GameLibrary/

## Key Paths on This System
- Emulators root: /Users/aidan/Emulators/
- Cemu: /Applications/Cemu.app
- Citra: /Users/aidan/Emulators/Nintendo/citra/nightly/citra-qt.app
- shadPS4: /Users/aidan/Emulators/Playstation/PS4/shadPS4QtLauncher.app

## PM Workflow
This project uses the PM session workflow.
See /Users/aidan/PROJECT_SCAFFOLD.md for the full process.
- PLAN.md = master plan with tasks and status
- SESSION.md = cross-session handoff log
- Update SESSION.md after every session
