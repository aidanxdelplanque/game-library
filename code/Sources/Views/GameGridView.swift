import SwiftUI
import AppKit

struct GameGridView: View {
    let games: [Game]
    let searchText: String
    let launchingGameID: UUID?
    let coverImageForGame: (Game) -> NSImage?
    let onLaunch: (Game) -> Void
    let onShowInFinder: (Game) -> Void
    let onCopyPath: (Game) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: 20)
    ]

    var body: some View {
        if games.isEmpty {
            if !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ContentUnavailableView(
                    "No Games",
                    systemImage: "gamecontroller",
                    description: Text("No games found for this platform.")
                )
            }
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(games) { game in
                        GameCardView(
                            game: game,
                            coverImage: coverImageForGame(game),
                            isLaunching: launchingGameID == game.id
                        ) {
                            onLaunch(game)
                        }
                        .contextMenu {
                            Button("Launch") {
                                onLaunch(game)
                            }
                            Divider()
                            Button("Show in Finder") {
                                onShowInFinder(game)
                            }
                            Button("Copy Path") {
                                onCopyPath(game)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}
