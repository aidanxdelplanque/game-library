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
            // Fixed 3:4 container — everything is clipped to this shape
            Color.clear
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .overlay {
                    // Cover art fills the entire frame, cropped to fit
                    if let coverImage {
                        Image(nsImage: coverImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(platformColor.gradient)
                            .overlay {
                                Text(game.platform.shortName)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                    }
                }
                .overlay(alignment: .bottom) {
                    // Title bar — always visible on every card
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)

                            Text(game.platform.shortName)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Text(game.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black.opacity(0.7), location: 0.3),
                                .init(color: .black.opacity(0.9), location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .scaleEffect(isLaunching ? 0.95 : (isHovered ? 1.03 : 1.0))
                .opacity(isLaunching ? 0.6 : 1.0)
                .shadow(color: .black.opacity(isHovered ? 0.35 : 0.15), radius: isHovered ? 10 : 5, y: isHovered ? 5 : 2)
                .animation(.easeOut(duration: 0.15), value: isHovered)
                .animation(.easeInOut(duration: 0.2), value: isLaunching)
                .onHover { hovering in
                    isHovered = hovering
                }
        }
        .buttonStyle(.plain)
    }
}
