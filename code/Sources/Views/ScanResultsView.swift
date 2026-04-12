import SwiftUI

struct ScanResultsView: View {
    let scannedGames: [ScannedGame]
    let onAdd: ([ScannedGame]) -> Void
    let onDismiss: () -> Void

    @State private var selected: Set<UUID>

    init(
        scannedGames: [ScannedGame],
        onAdd: @escaping ([ScannedGame]) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.scannedGames = scannedGames
        self.onAdd = onAdd
        self.onDismiss = onDismiss
        self._selected = State(initialValue: Set(scannedGames.map(\.id)))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Found \(scannedGames.count) new game\(scannedGames.count == 1 ? "" : "s")")
                    .font(.headline)
                Spacer()
                Button("Select All") { selected = Set(scannedGames.map(\.id)) }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                Button("Select None") { selected.removeAll() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
            }
            .padding()

            Divider()

            // Game list
            List {
                ForEach(scannedGames) { game in
                    HStack(spacing: 12) {
                        Toggle("", isOn: Binding(
                            get: { selected.contains(game.id) },
                            set: { isOn in
                                if isOn { selected.insert(game.id) }
                                else { selected.remove(game.id) }
                            }
                        ))
                        .toggleStyle(.checkbox)
                        .labelsHidden()

                        Image(systemName: game.platform.sfSymbolName)
                            .foregroundStyle(Color(hex: game.platform.colorHex))
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(game.title)
                                .font(.body.weight(.medium))
                            Text(game.platform.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if game.appPath.isEmpty {
                            Text("No emulator")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Divider()

            // Footer
            HStack {
                Text("\(selected.count) selected")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") { onDismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add Selected") {
                    let toAdd = scannedGames.filter { selected.contains($0.id) }
                    onAdd(toAdd)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(selected.isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}
