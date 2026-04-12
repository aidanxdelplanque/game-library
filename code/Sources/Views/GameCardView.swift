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
            VStack(spacing: 8) {
                // Cover art area
                ZStack(alignment: .topTrailing) {
                    if let coverImage {
                        Image(nsImage: coverImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(3.0 / 4.0, contentMode: .fit)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(platformColor.gradient)
                            .aspectRatio(3.0 / 4.0, contentMode: .fit)
                    }

                    // Platform badge
                    Text(game.platform.shortName)
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.55), in: Capsule())
                        .padding(8)
                }

                // Title and status below the art
                HStack(alignment: .top, spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 7, height: 7)
                        .padding(.top, 4)

                    Text(game.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 4)
            }
            .scaleEffect(isLaunching ? 0.95 : (isHovered ? 1.03 : 1.0))
            .opacity(isLaunching ? 0.6 : 1.0)
            .shadow(color: .black.opacity(isHovered ? 0.25 : 0.1), radius: isHovered ? 8 : 4, y: isHovered ? 4 : 2)
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: isLaunching)
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .buttonStyle(.plain)
    }
}
