import SwiftUI

struct ConnectionInsights: View {
    let avgLatency: Double?
    let packetLoss: Double

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connection Insights")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                if let latency = avgLatency {
                    VStack(alignment: .leading, spacing: 12) {
                        insightRow(
                            icon: qualityIcon(for: latency),
                            color: qualityColor(for: latency),
                            title: qualityTitle(for: latency),
                            description: qualityDescription(for: latency)
                        )

                        if packetLoss > 5 {
                            insightRow(
                                icon: "exclamationmark.triangle.fill",
                                color: NetworkTheme.accentOrange,
                                title: "Packet Loss Detected",
                                description: "You may experience connection drops or lag"
                            )
                        }

                        Divider()
                            .background(NetworkTheme.textTertiary.opacity(0.2))

                        whatYouCanDo(for: latency, loss: packetLoss)
                    }
                } else {
                    Text("Start monitoring to see connection insights")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(NetworkTheme.textSecondary)
                }
            }
        }
    }

    private func insightRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                Text(description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(NetworkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func whatYouCanDo(for latency: Double, loss: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What You Can Do")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(NetworkTheme.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                if latency < 50 {
                    recommendation(
                        icon: "checkmark.circle.fill",
                        text: "Perfect for gaming, video calls, and streaming",
                        color: NetworkTheme.accentGreen
                    )
                } else if latency < 100 {
                    recommendation(
                        icon: "wifi",
                        text: "Good for browsing and video calls",
                        color: NetworkTheme.accent
                    )
                    recommendation(
                        icon: "info.circle",
                        text: "Move closer to router for better performance",
                        color: NetworkTheme.accent
                    )
                } else if latency < 200 {
                    recommendation(
                        icon: "exclamationmark.triangle",
                        text: "May cause lag in games and video calls",
                        color: NetworkTheme.accentOrange
                    )
                    recommendation(
                        icon: "arrow.clockwise",
                        text: "Try restarting your router",
                        color: NetworkTheme.accentOrange
                    )
                } else {
                    recommendation(
                        icon: "xmark.circle",
                        text: "Connection too slow for real-time apps",
                        color: NetworkTheme.accentRed
                    )
                    recommendation(
                        icon: "phone",
                        text: "Contact your internet provider",
                        color: NetworkTheme.accentRed
                    )
                }

                if loss > 5 {
                    recommendation(
                        icon: "antenna.radiowaves.left.and.right",
                        text: "Check for WiFi interference from nearby networks",
                        color: NetworkTheme.accentOrange
                    )
                }
            }
        }
    }

    private func recommendation(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 16)

            Text(text)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(NetworkTheme.textSecondary)
        }
    }

    private func qualityIcon(for latency: Double) -> String {
        if latency < 50 { return "checkmark.seal.fill" }
        if latency < 100 { return "wifi" }
        if latency < 200 { return "exclamationmark.triangle.fill" }
        return "xmark.octagon.fill"
    }

    private func qualityColor(for latency: Double) -> Color {
        if latency < 50 { return NetworkTheme.accentGreen }
        if latency < 100 { return NetworkTheme.accent }
        if latency < 200 { return NetworkTheme.accentOrange }
        return NetworkTheme.accentRed
    }

    private func qualityTitle(for latency: Double) -> String {
        if latency < 50 { return "Excellent Connection" }
        if latency < 100 { return "Good Connection" }
        if latency < 200 { return "Fair Connection" }
        return "Poor Connection"
    }

    private func qualityDescription(for latency: Double) -> String {
        if latency < 50 {
            return "Your internet is performing great! Low latency means fast response times."
        }
        if latency < 100 {
            return "Your connection is good for most activities. Latency is the time it takes data to travel."
        }
        if latency < 200 {
            return "Your connection may feel slow. High latency means longer delays in communication."
        }
        return "Your connection is experiencing significant delays. This will impact all online activities."
    }
}
