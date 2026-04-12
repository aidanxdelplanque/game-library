# Game Library — Session Log
**Last updated:** 2026-04-11
**Session focus:** Full build from zero to installed app

## What happened
- Created project plan with 16-game inventory across Nintendo, PlayStation, PC
- Built Swift package with data models (Game, Platform, GameCatalog, GameLauncher)
- Built full SwiftUI UI: platform sidebar, game grid, cover art, search, context menus
- Found and fixed all launch commands (SoH was in /Applications, not a DMG)
- Downloaded cover art from Wikipedia for all 15 games (10 URLs needed fixing)
- Improved grid tiling: bigger cards, title below art, 3:4 aspect ratio
- Created build-app.sh for proper .app bundle generation
- Added custom AI-generated app icon (AppIcon.icns)
- Installed to /Applications/Game Library.app with dock icon
- Pushed to github.com/aidanxdelplanque/game-library

## Decisions made
- SwiftUI with MVVM (data layer independent of views for future server use)
- Swift Package Manager over Xcode project for CLI-friendly builds
- Wikipedia cover art (free, no API key needed)
- Title below cover art instead of overlaid for cleaner look
- build-app.sh script for rebuild/reinstall workflow

## Blockers / Open questions
- Some games still marked "untested" — need to click each and verify launch
- Sly Cooper marked "broken" (recomp project not ready yet)
- shadPS4 has no games downloaded yet
- Cover art is Wikipedia quality (small) — could upgrade to SteamGridDB for higher res

## Next session should
- Test all game launches and mark status as working/broken
- Task 2.1: Favorites & Recently Played
- Task 2.2: Auto-scan for new games
- Consider higher-res cover art source (SteamGridDB API)
- Parked: remote streaming architecture
