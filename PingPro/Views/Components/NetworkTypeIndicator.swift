import SwiftUI

struct NetworkTypeIndicator: View {
    let networkType: NetworkType

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: networkType.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(networkType.rawValue)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Capsule()
                    .fill(backgroundColor.opacity(0.2))
                    .blur(radius: 1)

                Capsule()
                    .fill(.ultraThinMaterial.opacity(0.6))
            }
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            iconColor.opacity(0.6),
                            iconColor.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: iconColor.opacity(0.3), radius: 8, y: 4)
    }

    private var iconColor: Color {
        switch networkType {
        case .wifi:
            return NetworkTheme.accent
        case .cellular:
            return NetworkTheme.accentGreen
        case .wired:
            return NetworkTheme.accent
        case .unknown:
            return NetworkTheme.textSecondary
        }
    }

    private var backgroundColor: Color {
        switch networkType {
        case .wifi:
            return NetworkTheme.accent
        case .cellular:
            return NetworkTheme.accentGreen
        case .wired:
            return NetworkTheme.accent
        case .unknown:
            return NetworkTheme.textSecondary
        }
    }
}
