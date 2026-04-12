# Game Library — Session Log
**Last updated:** 2026-04-11
**Session focus:** Project creation and planning

## What happened
- Inventoried all emulators and games on the system under /Users/aidan/Emulators/
- Identified 16 games across Nintendo (SoH, 2Ship, sm64ex, Cemu, Citra), PlayStation (OpenGOAL, shadPS4, Sly Cooper), and PC (DevilutionX, Fallout 1 & 2 CE)
- Chose SwiftUI for native macOS app (instant launch, single dock icon)
- Created PLAN.md with full game inventory, launch commands, and phased task breakdown
- Noted future streaming requirement — architecture keeps data layer separate from UI
- Added absolute rule: launcher never touches emulator configs or settings

## Decisions made
- SwiftUI over web UI for instant launch and native feel
- MVVM with SwiftUI-independent data layer (future server extraction)
- SteamGridDB or IGDB for cover art sourcing
- JSON-based game catalog as source of truth
- Swift Package Manager (not Xcode project) for CLI-friendly builds

## Blockers / Open questions
- Several launch commands still TBD (SoH, 2Ship, DevilutionX, OpenGOAL, Fallout 2 CE, shadPS4) — need filesystem inspection during Task 0.3
- Sly Cooper may not be playable yet (recomp project in progress)
- Cover art API choice not finalized (SteamGridDB vs IGDB)

## Next session should
- Start implementation: Task 0.1 (Swift package setup) → 0.2 (data models) → 0.3 (game catalog with real launch commands)
