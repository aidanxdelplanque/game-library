import SwiftUI
import AppKit

struct SetupView: View {
    let onComplete: (String) -> Void

    @State private var selectedPath: String = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Welcome to Game Library")
                .font(.largeTitle.bold())

            Text("Select the folder where your emulators and ROMs are stored.\nGame Library will scan it to find your games.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 400)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.blue)
                    if selectedPath.isEmpty {
                        Text("No folder selected")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(selectedPath)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Button("Browse...") {
                        chooseFolder()
                    }
                }
                .padding(12)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 450)
            }

            Button {
                guard !selectedPath.isEmpty else {
                    showError = true
                    return
                }
                onComplete(selectedPath)
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(width: 160)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedPath.isEmpty)

            Spacer()
        }
        .padding(40)
        .frame(minWidth: 550, minHeight: 400)
        .alert("Please select a folder", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.title = "Select Emulators Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            selectedPath = url.path
        }
    }
}
