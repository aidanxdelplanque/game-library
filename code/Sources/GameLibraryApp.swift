import SwiftUI

@main
struct GameLibraryApp: App {
    var body: some Scene {
        WindowGroup("Game Library") {
            ContentView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 900, height: 600)
    }
}
