# Game Library

A native macOS app that replaces a dock full of emulators and PC ports with one clean launcher. Browse your games as a grid of cover art, click to play.

## Features

- **Unified launcher** — one app for all your emulators and PC game ports
- **Auto-scan** — point it at your emulators folder and it discovers your games automatically
- **Cover art** — downloads box art from libretro-thumbnails (with Wikipedia fallback)
- **Emulator settings** — open any emulator directly from the toolbar for configuration
- **Platform sidebar** — filter by system (N64, GameCube, Wii U, 3DS, PS2, PS4, PC)
- **Search** — find any game instantly with Cmd+F
- **Auto-extract** — automatically unzips compressed ROMs during scan
- **Settings** — change your emulators folder anytime via Preferences (Cmd+,)

## Supported Emulators

| Emulator | Systems | ROM Formats |
|----------|---------|-------------|
| [Parallel Launcher](https://parallel-launcher.ca) | Nintendo 64 | .z64, .n64, .v64 |
| [Dolphin](https://dolphin-emu.org) | GameCube, Wii | .iso, .gcm, .wbfs, .wia, .rvz |
| [Cemu](https://cemu.info) | Wii U | .wux, .wud, folder format |
| [Citra](https://citra-emu.org) | Nintendo 3DS | .3ds, .cia |
| [PCSX2](https://pcsx2.net) | PlayStation 2 | .iso, .bin, .chd, .cso |
| [shadPS4](https://shadps4.net) | PlayStation 4 | eboot.bin folders |
| [OpenGOAL](https://opengoal.dev) | PS2 (Jak series) | Custom binary |
| [Ship of Harkinian](https://shipofharkinian.com) | N64 (Zelda OoT) | Native port |
| [2Ship](https://github.com/HarbourMasters64/2ship2harkinian) | N64 (Zelda MM) | Native port |
| [sm64ex](https://github.com/sm64pc/sm64ex) | N64 (Mario 64) | Native port |
| [DevilutionX](https://github.com/diasurgical/devilutionX) | PC (Diablo) | Native port |
| [Fallout CE](https://github.com/alexbatalov/fallout1-ce) | PC (Fallout 1/2) | Native port |

## Requirements

- **macOS 14 (Sonoma) or later** — this is a native macOS app (SwiftUI + AppKit) and does not run on Windows or Linux
- Your emulators installed (either in /Applications or in your emulators folder)
- ROM files in your emulators folder

## Setup

### From source

```bash
git clone https://github.com/aidanxdelplanque/game-library.git
cd game-library/code
swift build -c release
bash build-app.sh
cp -R "Game Library.app" /Applications/
```

### First launch

1. Open Game Library
2. Select your emulators folder (e.g. `~/Emulators`)
3. The app scans the folder and discovers your games
4. Cover art downloads automatically

### Folder structure

Game Library expects your emulators folder to be organized by system. Example:

```
~/Emulators/
├── Nintendo/
│   ├── dolphin/          ← GameCube/Wii ROMs here
│   ├── Cemu/             ← Wii U ROMs (.wux or folder format)
│   ├── citra/            ← 3DS ROMs
│   ├── N64/              ← N64 ROMs (Parallel Launcher)
│   ├── sm64ex/           ← SM64 native port
│   ├── Ship of Harkinian/
│   └── 2 Ship 2 Harkinian/
├── Playstation/
│   ├── ps2/              ← PS2 ISOs (PCSX2)
│   ├── OpenGOAL/         ← Jak & Daxter ports
│   ├── PS4/Games/        ← shadPS4 game folders
│   └── Sly Cooper/
└── PC/
    ├── DevilutionX/
    ├── Fallout 1 CE/
    └── Fallout 2 CE/
```

## Adding games

There are two ways to add games:

1. **Auto-scan** — click the scan button (magnifying glass) in the toolbar. The app finds new ROMs and lets you pick which to add.
2. **Manual** — drop ROM files into the appropriate subfolder in your emulators directory, then scan.

## Cover art

Cover art is sourced from [libretro-thumbnails](https://github.com/libretro-thumbnails) with Wikipedia as a fallback, and cached in `~/Library/Caches/GameLibrary/covers/`. Use the "Cover Art" toolbar menu to find missing art or refresh all art.

## Settings

Open Preferences (Cmd+,) to change your emulators folder path.

## Architecture

The app uses MVVM with a SwiftUI frontend and a SwiftUI-independent data layer:

- **Models/** — `Game`, `Platform` (plain Swift, Codable)
- **Services/** — `GameCatalog`, `GameLauncher`, `GameScanner`, `CoverArtService`, `AppSettings`
- **ViewModels/** — `LibraryViewModel`
- **Views/** — SwiftUI views

The data layer is kept independent of SwiftUI for potential future use as a server for remote game streaming.

## Data storage

- Game catalog: `~/Library/Application Support/GameLibrary/games.json`
- Cover art cache: `~/Library/Caches/GameLibrary/covers/`
- Settings: macOS UserDefaults

## License

MIT
