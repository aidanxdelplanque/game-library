import SwiftUI

struct PlatformSidebar: View {
    @Binding var selectedPlatform: Platform?
    let gameCount: (Platform) -> Int
    let totalGameCount: Int

    private var sortedPlatforms: [Platform] {
        Platform.allCases.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        List(selection: $selectedPlatform) {
            // "All Games" row — represented by nil selection
            Button {
                selectedPlatform = nil
            } label: {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    Text("All Games")
                    Spacer()
                    Text("\(totalGameCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 2)
            .listRowBackground(
                selectedPlatform == nil
                    ? RoundedRectangle(cornerRadius: 4).fill(.selection)
                    : nil
            )

            Section("Platforms") {
                ForEach(sortedPlatforms) { platform in
                    Button {
                        selectedPlatform = platform
                    } label: {
                        HStack {
                            Image(systemName: platform.sfSymbolName)
                                .foregroundStyle(Color(hex: platform.colorHex))
                                .frame(width: 20)
                            Text(platform.shortName)
                            Spacer()
                            Text("\(gameCount(platform))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                    .listRowBackground(
                        selectedPlatform == platform
                            ? RoundedRectangle(cornerRadius: 4).fill(.selection)
                            : nil
                    )
                }
            }
        }
        .listStyle(.sidebar)
    }
}
