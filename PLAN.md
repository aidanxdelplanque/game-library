================================================================================
GAME LIBRARY v0.1 — MASTER PLAN
Unified macOS game launcher for emulators and native PC ports
================================================================================

PURPOSE
-------
A single SwiftUI app that replaces a dock full of emulators and ports with one
clean grid of games organized by system. Browse cover art, click to play.
Everything on the machine launches from one place.

PROJECT LOCATION: /Users/aidan/projects/game-library/
CODE DIRECTORY:    /Users/aidan/projects/game-library/code/
COLLABORATORS:     Solo (Aidan)

EMULATORS ROOT:    /Users/aidan/Emulators/

ABSOLUTE RULES (apply to every session)
----------------------------------------
1. macOS-only. SwiftUI with minimum deployment target macOS 14 (Sonoma).
2. Keep the game catalog / data layer independent of SwiftUI views (MVVM).
   This layer will eventually become a server for remote streaming.
3. All launch commands must be tested on Aidan's actual system before
   marking a game as working.
4. Cover art is fetched from the internet and cached locally — never
   ship copyrighted assets in the repo.
5. THE LAUNCHER IS A THIN LAYER. It opens apps/emulators exactly as the
   user would from Finder. It NEVER modifies emulator configs, controller
   mappings, resolution settings, save data, or any files inside the
   emulators/ports themselves. Each game's settings are managed within
   that game's own app — the launcher just launches.

================================================================================
GAME INVENTORY
================================================================================

The app must support every game/emulator combo below. Each entry lists the
title, system, emulator/port, known paths, and launch method.

NINTENDO
--------
  1. The Legend of Zelda: Ocarina of Time
     Port: Ship of Harkinian (SoH)
     Path: /Users/aidan/Emulators/Nintendo/Ship of Harkinian/
     App:  SoH-Ackbar-Bravo-Mac (directory — find executable inside)
     ROM:  Legend of Zelda, The - Ocarina of Time (U) (V1.2) [!].z64
     Launch: TBD — locate executable in SoH-Ackbar-Bravo-Mac

  2. The Legend of Zelda: Majora's Mask
     Port: 2 Ship 2 Harkinian (2Ship)
     Path: /Users/aidan/Emulators/Nintendo/2 Ship 2 Harkinian/
     App:  2Ship.dmg (may need installation)
     ROM:  Legend of Zelda, The - Majora's Mask (USA).z64
     Launch: TBD — check if dmg is installed, find executable

  3. Super Mario 64
     Port: sm64ex
     Path: /Users/aidan/Emulators/Nintendo/sm64ex/
     App:  sm64ex.app
     Launch: open "/Users/aidan/Emulators/Nintendo/sm64ex/sm64ex.app"

  4. The Legend of Zelda: Breath of the Wild
     Emulator: Cemu (Wii U)
     App:  /Applications/Cemu.app
     ROM:  /Users/aidan/Emulators/Nintendo/Cemu/Legend of Zelda The - Breath of the Wild (USA) (EnFrEs)/Legend of Zelda, The - Breath of the Wild (USA) (En,Fr,Es).wux
     Launch: open /Applications/Cemu.app --args -g "<rom_path>"

  5. The Legend of Zelda: The Wind Waker HD
     Emulator: Cemu (Wii U)
     App:  /Applications/Cemu.app
     ROM:  /Users/aidan/Emulators/Nintendo/Cemu/Legend of Zelda The - The Wind Waker HD (USA Asia) (EnFrEs)/Legend of Zelda, The - The Wind Waker HD (USA, Asia) (En,Fr,Es).wux
     Launch: open /Applications/Cemu.app --args -g "<rom_path>"

  6. The Legend of Zelda: Twilight Princess HD
     Emulator: Cemu (Wii U)
     App:  /Applications/Cemu.app
     ROM:  /Users/aidan/Emulators/Nintendo/Cemu/Legend of Zelda The - Twilight Princess HD (USA) (EnFrEs) (Rev 2)/Legend of Zelda, The - Twilight Princess HD (USA) (En,Fr,Es) (Rev 2).wux
     Launch: open /Applications/Cemu.app --args -g "<rom_path>"

  7. The Legend of Zelda: A Link Between Worlds
     Emulator: Citra (3DS)
     App:  /Users/aidan/Emulators/Nintendo/citra/nightly/citra-qt.app
     ROM:  /Users/aidan/Emulators/Nintendo/citra/Legend of Zelda, The - A Link Between Worlds (USA) (En,Fr,Es).3ds
     Launch: open "<citra_app>" --args "<rom_path>"

PLAYSTATION
-----------
  9. Jak and Daxter: The Precursor Legacy
     Port: OpenGOAL (PS2 decompilation)
     Path: /Users/aidan/Emulators/Playstation/OpenGOAL/active/jak1/
     Launch: TBD — find OpenGOAL executable/launcher

  10. Jak II
      Port: OpenGOAL (PS2 decompilation)
      Path: /Users/aidan/Emulators/Playstation/OpenGOAL/active/jak2/
      Launch: TBD — find OpenGOAL executable/launcher

  11. Jak 3
      Port: OpenGOAL (PS2 decompilation)
      ISO:  /Users/aidan/Emulators/Playstation/OpenGOAL/Jak 3 (USA) (En,Fr,De,Es,It,Pt,Ru).iso
      Launch: TBD — may not be set up yet, check if extracted

  12. Sly Cooper and the Thievius Raccoonus
      ISO:  /Users/aidan/Emulators/Playstation/Sly Cooper/Sly Cooper and the Thievius Raccoonus (USA).iso
      Launch: TBD — user has a recomp project in progress, may not be playable yet

  13. PS4 Games (shadPS4)
      App:  /Users/aidan/Emulators/Playstation/PS4/shadPS4QtLauncher.app
      Games: /Users/aidan/Emulators/Playstation/PS4/Games/
      Launch: TBD — check shadPS4 CLI args

PC PORTS
--------
  14. Diablo
      Port: DevilutionX
      Path: /Users/aidan/Emulators/PC/DevilutionX/
      Launch: TBD — no .app found, may need installation

  15. Fallout
      Port: Fallout Community Edition
      App:  /Users/aidan/Emulators/PC/Fallout 1 CE/Fallout Community Edition.app
      Launch: open "/Users/aidan/Emulators/PC/Fallout 1 CE/Fallout Community Edition.app"

  16. Fallout 2
      Port: Fallout 2 Community Edition
      Path: /Users/aidan/Emulators/PC/Fallout 2 CE/
      App:  fallout2-ce-macos.dmg (may need installation)
      Launch: TBD — check if dmg is installed

================================================================================
PHASE 0: FOUNDATION
Must be completed before anything else.
================================================================================

TASK 0.1 — Swift Package Setup
  Description: Create a SwiftUI macOS app using Swift Package Manager.
    - Package.swift targeting macOS 14+
    - Executable target "GameLibrary"
    - Basic App struct with a window
    - Build script that compiles and optionally creates a .app bundle
    - Verify it builds and launches with `swift build && swift run`
  Deliverable: A window appears on screen when you run the app.
  Depends on: Nothing
  Files: code/Package.swift, code/Sources/GameLibraryApp.swift

TASK 0.2 — Data Models
  Description: Define the core data models that represent the game catalog.
    - Game: id, title, system (enum), coverArtURL, coverArtLocalPath,
      launchType (enum: app, emulatorWithROM, custom), appPath, romPath,
      emulatorArgs, status (working/untested/broken)
    - Platform: enum with cases for each system (N64, WiiU, 3DS, PS2, PS4, PC)
      with display name, icon/color, and sort order
    - GameCatalog: loads/saves the game list from a JSON file
    Keep models Codable for JSON serialization. Keep them independent of
    SwiftUI (plain Swift structs/classes) for future server use.
  Deliverable: Models compile. A test catalog JSON can be loaded and printed.
  Depends on: 0.1
  Files: code/Sources/Models/Game.swift, code/Sources/Models/Platform.swift,
         code/Sources/Services/GameCatalog.swift

TASK 0.3 — Game Catalog & Launch Commands
  Description: Create the master games.json catalog with every game from the
    inventory above. For each game, determine the exact launch command by
    inspecting the filesystem:
    - Find executables inside SoH-Ackbar-Bravo-Mac, 2Ship.dmg contents,
      DevilutionX, OpenGOAL, Fallout 2 CE
    - Test each launch command manually (open the app/run the command)
    - Record working launch commands in games.json
    - Mark games as "untested" or "broken" if they can't be launched yet
    Also create the GameLauncher service that takes a Game and executes
    the correct launch command via Process/NSWorkspace.
  Deliverable: games.json with all 16 games. GameLauncher can launch at
    least the confirmed-working games (sm64ex, Fallout 1 CE, Cemu titles,
    Citra title).
  Depends on: 0.2
  Files: code/Resources/games.json, code/Sources/Services/GameLauncher.swift

================================================================================
PHASE 1: UI
Build the SwiftUI interface.
================================================================================

TASK 1.1 — Platform Sidebar + Game Grid Shell
  Description: Create the main app layout:
    - Left sidebar listing platforms (Nintendo, PlayStation, PC, All)
      with system icons/colors
    - Main content area with a grid of game cards
    - Each card shows the game title, platform badge, and a placeholder
      image (colored rectangle with initials)
    - Clicking a card launches the game via GameLauncher
    - "All" filter shows everything; platform filters show that system only
    Use NavigationSplitView for the sidebar layout.
  Deliverable: App shows sidebar + grid. Clicking a game launches it.
  Depends on: 0.3
  Files: code/Sources/Views/ContentView.swift,
         code/Sources/Views/GameGridView.swift,
         code/Sources/Views/GameCardView.swift,
         code/Sources/Views/PlatformSidebar.swift

TASK 1.2 — Cover Art System
  Description: Fetch and display cover art for each game.
    - Use SteamGridDB API (free, designed for launchers) or IGDB API
      to search for game cover art by title
    - Download art and cache it locally in ~/Library/Caches/GameLibrary/
    - Display cached art on game cards (AsyncImage or similar)
    - Fallback to styled placeholder if no art found
    - Add a manual override: user can drag-drop or paste a custom image
    Also fetch a small icon/logo for each platform (N64, Wii U, 3DS, PS2, etc.)
    to display in the sidebar and on game cards.
  Deliverable: Game grid shows real cover art for all games.
  Depends on: 1.1
  Files: code/Sources/Services/CoverArtService.swift,
         code/Sources/Views/GameCardView.swift (update)

TASK 1.3 — Search & Polish
  Description: Add usability features:
    - Search bar that filters games by title (cmd+F or always visible)
    - Subtle launch animation / feedback when a game is clicked
    - Status indicator on cards (green dot = working, yellow = untested,
      red = broken)
    - Keyboard navigation (arrow keys to browse, Enter to launch)
    - Remember window size/position between launches
  Deliverable: Polished, usable launcher.
  Depends on: 1.2
  Files: code/Sources/Views/ (various)

================================================================================
PHASE 2: EXTRAS
Nice-to-haves after core is solid.
================================================================================

TASK 2.1 — Favorites & Recently Played
  Description: Track launch history and let user mark favorites.
    - "Favorites" section at the top of All view or in sidebar
    - "Recently Played" section showing last 5 launched games with timestamp
    - Persist to a local JSON file in app support directory
  Deliverable: Favorites and recents work across app restarts.
  Depends on: 1.3
  Files: code/Sources/Services/UserData.swift, code/Sources/Views/ (updates)

TASK 2.2 — Auto-Scan for New Games
  Description: On launch (or via menu item), scan /Users/aidan/Emulators/
    for new ROMs/apps that aren't in the catalog yet. Present a list of
    discovered games and let the user confirm adding them.
  Deliverable: Adding a new ROM to the Emulators folder gets detected.
  Depends on: 1.3
  Files: code/Sources/Services/GameScanner.swift

================================================================================
STATUS TRACKER
================================================================================
  Task  0.1  Swift Package Setup ..................... DONE
  Task  0.2  Data Models ............................ DONE
  Task  0.3  Game Catalog & Launch Commands ......... DONE
  Task  1.1  Platform Sidebar + Game Grid Shell ..... DONE
  Task  1.2  Cover Art System ....................... DONE
  Task  1.3  Search & Polish ........................ DONE
  Task  2.1  Favorites & Recently Played ............ TODO
  Task  2.2  Auto-Scan for New Games ................ TODO

================================================================================
DEPENDENCY MAP
================================================================================

  0.1 Swift Package Setup
   └── 0.2 Data Models
        └── 0.3 Game Catalog & Launch Commands
             └── 1.1 Platform Sidebar + Game Grid
                  └── 1.2 Cover Art System
                       └── 1.3 Search & Polish
                            ├── 2.1 Favorites & Recently Played
                            └── 2.2 Auto-Scan for New Games  (parallel w/ 2.1)

  PARALLELIZABLE WORK:
    - Tasks 2.1 and 2.2 can run simultaneously

================================================================================
PARKED (future versions)
================================================================================
- Remote streaming: expose game catalog via REST API, add web client for
  phone/tablet, integrate with Sunshine/Moonlight for actual game streaming
- Controller support: detect connected controllers, show in UI
- Per-game settings: resolution, fullscreen, controller mapping overrides
- Import/export: share game library config between machines
================================================================================
