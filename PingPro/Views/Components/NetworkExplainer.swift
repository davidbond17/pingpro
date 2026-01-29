import SwiftUI

struct NetworkExplainer: View {
    let avgLatency: Double?
    let packetLoss: Double

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(NetworkTheme.accent)
                    Text("What This Means")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(NetworkTheme.textPrimary)
                }

                if let latency = avgLatency {
                    VStack(alignment: .leading, spacing: 10) {
                        explanationItem(
                            title: connectionQuality(latency),
                            description: connectionExplanation(latency),
                            color: connectionColor(latency)
                        )

                        if packetLoss < 1 {
                            explanationItem(
                                title: "Stable Connection",
                                description: "No packet loss - perfect for streaming and calls",
                                color: NetworkTheme.accentGreen
                            )
                        } else if packetLoss < 5 {
                            explanationItem(
                                title: "Minor Packet Loss",
                                description: "Some data is being lost - may notice occasional stuttering",
                                color: NetworkTheme.accentOrange
                            )
                        } else {
                            explanationItem(
                                title: "High Packet Loss",
                                description: "Significant data loss - expect drops and lag",
                                color: NetworkTheme.accentRed
                            )
                        }
                    }
                } else {
                    Text("Start monitoring to see your connection quality")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(NetworkTheme.textSecondary)
                }
            }
        }
    }

    private func explanationItem(title: String, description: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(color)

            Text(description)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(NetworkTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func connectionQuality(_ latency: Double) -> String {
        if latency < 50 { return "Excellent - Great for Gaming" }
        if latency < 100 { return "Good - Perfect for Video Calls" }
        if latency < 200 { return "Fair - May Feel Slow" }
        return "Poor - Expect Delays"
    }

    private func connectionExplanation(_ latency: Double) -> String {
        if latency < 50 {
            return "Your ping is under 50ms - fast response times for all activities"
        }
        if latency < 100 {
            return "Your ping is good - suitable for streaming and browsing"
        }
        if latency < 200 {
            return "Your ping is high - you may notice lag in real-time apps"
        }
        return "Your ping is very high - try moving closer to your router or restarting it"
    }

    private func connectionColor(_ latency: Double) -> Color {
        if latency < 50 { return NetworkTheme.accentGreen }
        if latency < 100 { return NetworkTheme.accent }
        if latency < 200 { return NetworkTheme.accentOrange }
        return NetworkTheme.accentRed
    }
}
