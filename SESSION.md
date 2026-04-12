# Game Library — Session Log
**Last updated:** 2026-04-12
**Session focus:** Fix launch issues, add game scanner, Dolphin support

## What happened
- Fixed SM64 launch — .app bundle was broken (bad CFBundleExecutable + dylibbundler issues), switched to raw binary at sm64ex-src/build/us_pc/sm64.us.f3dex2e
- Fixed Jak 1 & 2 (OpenGOAL) launches — needed --proj-path pointing to active/jakN/data and workingDirectory set on Process
- Fixed all .app launches — replaced NSWorkspace.openApplication with /usr/bin/open (more reliable for non-standard bundles)
- Added Game model field: workingDirectory (for custom launch types)
- Removed Assassin's Creed IV: Black Flag (decrypt key didn't work, deleted ROM + catalog entry)
- Added GameCube platform with purple color (#6A0DAD)
- Installed Dolphin 2603a to /Applications/Dolphin.app
- Built auto-scan feature (Task 2.2): scans ~/Emulators for new ROMs, shows confirmation UI
- Scanner auto-extracts .zip ROMs (Dolphin games were zipped, now .rvz)
- Added 4 Dolphin/GameCube games: Luigi's Mansion, NFS Most Wanted, Sonic Adventure 2 Battle, Star Fox Adventures
- Found Pikmin 2 (Cemu folder format) — scanner detects it but not yet added
- Migrated catalog to ~/Library/Application Support/GameLibrary/games.json (user-writable, persists across rebuilds)
- Added "Find Art" toolbar button — looks up Wikipedia cover art for games missing artwork
- Added "Scan for Games" toolbar button
- Cover art found and downloading for all games

## Decisions made
- Use /usr/bin/open for all .app launches instead of NSWorkspace (more reliable)
- OpenGOAL gk binary runs via Rosetta (x86_64 on arm64) — works fine
- Catalog lives in App Support now, not baked into the bundle
- Known cover art URLs stored in GameScanner.knownCoverArt dictionary
- Dolphin launches via `open /Applications/Dolphin.app --args -e <rom_path>`

## Blockers / Open questions
- Pikmin 2 detected by scanner but needs Cemu title key to play
- Jak 3 marked broken (ISO exists but not extracted/set up in OpenGOAL)
- Sly Cooper still broken (recomp project not ready)
- shadPS4 has no games downloaded yet
- Some games still marked "untested" — need user to verify each launch

## Next session should
- Task 2.1: Favorites & Recently Played
- Test all game launches and update status to working/broken
- Consider higher-res cover art source (SteamGridDB API)
- Add more games to knownCoverArt dictionary as library grows
- Parked: remote streaming architecture
