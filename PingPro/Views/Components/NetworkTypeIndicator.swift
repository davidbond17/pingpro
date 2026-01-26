import SwiftUI

struct NetworkTypeIndicator: View {
    let networkType: NetworkType

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: networkType.iconName)
                .font(.system(size: 14, weight: .semibold))

            Text(networkType.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .clipShape(Capsule())
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
