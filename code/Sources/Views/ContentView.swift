import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()

    private var gameCountLabel: String {
        let count = viewModel.filteredGames.count
        return count == 1 ? "1 game" : "\(count) games"
    }

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
                searchText: viewModel.searchText,
                launchingGameID: viewModel.launchingGameID,
                coverImageForGame: { viewModel.coverImage(for: $0) },
                onLaunch: { viewModel.launch(game: $0) },
                onShowInFinder: { viewModel.showInFinder(game: $0) },
                onCopyPath: { viewModel.copyPath(game: $0) }
            )
            .navigationTitle(
                viewModel.selectedPlatform?.displayName ?? "All Games"
            )
            .searchable(
                text: $viewModel.searchText,
                placement: .toolbar,
                prompt: "Search games"
            )
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Text(gameCountLabel)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.findMissingArt()
                    } label: {
                        Label("Find Art", systemImage: "photo.badge.arrow.down")
                    }
                    .help("Find cover art for games missing artwork")
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.scanForGames()
                    } label: {
                        Label("Scan for Games", systemImage: "plus.magnifyingglass")
                    }
                    .help("Scan Emulators folder for new games")
                }
            }
            .sheet(isPresented: $viewModel.showingScanResults) {
                ScanResultsView(
                    scannedGames: viewModel.scannedGames,
                    onAdd: { viewModel.addScannedGames($0) },
                    onDismiss: { viewModel.showingScanResults = false }
                )
            }
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
