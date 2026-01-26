import SwiftUI

struct ConnectionQualityBadge: View {
    let quality: ConnectionQuality

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.qualityColor(for: quality))
                .frame(width: 8, height: 8)

            Text(quality.label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.qualityColor(for: quality))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Color.qualityColor(for: quality).opacity(0.15)
        )
        .clipShape(Capsule())
    }
}
