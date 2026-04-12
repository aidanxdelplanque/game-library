import SwiftUI

struct GameCardView: View {
    let game: Game
    let onLaunch: () -> Void

    @State private var isHovered = false

    private var platformColor: Color {
        Color(hex: game.platform.colorHex)
    }

    private var statusColor: Color {
        switch game.status {
        case .working:  return .green
        case .untested: return .yellow
        case .broken:   return .red
        }
    }

    var body: some View {
        Button(action: onLaunch) {
            ZStack(alignment: .bottom) {
                // Placeholder cover: colored rectangle in 2:3 aspect ratio
                RoundedRectangle(cornerRadius: 8)
                    .fill(platformColor.gradient)
                    .aspectRatio(2.0 / 3.0, contentMode: .fit)
                    .overlay(alignment: .topTrailing) {
                        // Platform badge
                        Text(game.platform.shortName)
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.black.opacity(0.5), in: Capsule())
                            .padding(8)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        // Status indicator
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                            .shadow(color: statusColor.opacity(0.5), radius: 2)
                            .padding(10)
                    }

                // Title bar at the bottom
                VStack {
                    Spacer()
                    Text(game.title)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .scaleEffect(isHovered ? 1.04 : 1.0)
            .shadow(color: .black.opacity(isHovered ? 0.3 : 0.15), radius: isHovered ? 8 : 4)
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .buttonStyle(.plain)
    }
}
