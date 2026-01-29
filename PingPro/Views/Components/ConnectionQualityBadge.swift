import SwiftUI

struct ConnectionQualityBadge: View {
    let quality: ConnectionQuality

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.qualityColor(for: quality).opacity(0.3))
                    .frame(width: 16, height: 16)
                    .blur(radius: 2)

                Circle()
                    .fill(Color.qualityColor(for: quality))
                    .frame(width: 10, height: 10)
            }

            Text(quality.label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            ZStack {
                Capsule()
                    .fill(Color.qualityColor(for: quality).opacity(0.15))
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
                            Color.qualityColor(for: quality).opacity(0.5),
                            Color.qualityColor(for: quality).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.qualityColor(for: quality).opacity(0.3), radius: 8, y: 4)
    }
}
