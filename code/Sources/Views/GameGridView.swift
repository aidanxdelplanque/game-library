import SwiftUI
import AppKit

struct GameGridView: View {
    let games: [Game]
    let coverImageForGame: (Game) -> NSImage?
    let onLaunch: (Game) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        if games.isEmpty {
            ContentUnavailableView(
                "No Games",
                systemImage: "gamecontroller",
                description: Text("No games found for this platform.")
            )
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(games) { game in
                        GameCardView(
                            game: game,
                            coverImage: coverImageForGame(game)
                        ) {
                            onLaunch(game)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
