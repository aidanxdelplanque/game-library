import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()

    var body: some View {
        NavigationSplitView {
            PlatformSidebar(
                selectedPlatform: $viewModel.selectedPlatform,
                gameCount: { viewModel.gameCount(for: $0) },
                totalGameCount: viewModel.games.count
            )
            .navigationSplitViewColumnWidth(min: 160, ideal: 200)
        } detail: {
            GameGridView(
                games: viewModel.filteredGames,
                coverImageForGame: { viewModel.coverImage(for: $0) }
            ) { game in
                viewModel.launch(game: game)
            }
            .navigationTitle(
                viewModel.selectedPlatform?.displayName ?? "All Games"
            )
        }
        .onAppear {
            viewModel.loadCatalog()
        }
        .alert(
            "Launch Error",
            isPresented: Binding(
                get: { viewModel.launchError != nil },
                set: { if !$0 { viewModel.launchError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.launchError {
                Text(error)
            }
        }
    }
}
