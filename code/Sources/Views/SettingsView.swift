import SwiftUI
import AppKit

struct SettingsView: View {
    @State private var emulatorsPath: String = AppSettings.shared.emulatorsRoot ?? ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Emulators Folder") {
                HStack {
                    TextField("Path to emulators folder", text: $emulatorsPath)
                        .textFieldStyle(.roundedBorder)
                    Button("Browse...") {
                        chooseFolder()
                    }
                }
                Text("Game Library scans this folder to discover your games and emulators.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 150)
        .onChange(of: emulatorsPath) { _, newValue in
            AppSettings.shared.emulatorsRoot = newValue
        }
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.title = "Select Emulators Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false

        if let current = AppSettings.shared.emulatorsRoot {
            panel.directoryURL = URL(fileURLWithPath: current)
        }

        if panel.runModal() == .OK, let url = panel.url {
            emulatorsPath = url.path
        }
    }
}
