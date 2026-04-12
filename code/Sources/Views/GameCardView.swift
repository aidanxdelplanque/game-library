import SwiftUI
import AppKit

struct GameCardView: View {
    let game: Game
    let coverImage: NSImage?
    let isLaunching: Bool
    let onLaunch: () -> Void

    @State private var isHovered = false

    init(game: Game, coverImage: NSImage? = nil, isLaunching: Bool = false, onLaunch: @escaping () -> Void) {
        self.game = game
        self.coverImage = coverImage
        self.isLaunching = isLaunching
        self.onLaunch = onLaunch
    }

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
                // Cover art or fallback colored rectangle, in 2:3 aspect ratio
                if let coverImage {
                    Image(nsImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .aspectRatio(2.0 / 3.0, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(platformColor.gradient)
                        .aspectRatio(2.0 / 3.0, contentMode: .fit)
                }

                // Overlays (platform badge + status dot + title) on top of everything
                RoundedRectangle(cornerRadius: 8)
                    .fill(.clear)
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
            .scaleEffect(isLaunching ? 0.95 : (isHovered ? 1.04 : 1.0))
            .opacity(isLaunching ? 0.6 : 1.0)
            .shadow(color: .black.opacity(isHovered ? 0.3 : 0.15), radius: isHovered ? 8 : 4)
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: isLaunching)
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .buttonStyle(.plain)
    }
}
