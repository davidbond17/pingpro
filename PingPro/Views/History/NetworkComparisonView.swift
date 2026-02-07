import SwiftUI
import SwiftData

struct NetworkComparisonView: View {
    let sessions: [PingSession]

    private var wifiSessions: [PingSession] {
        sessions.filter { $0.networkType == .wifi && !$0.results.isEmpty }
    }

    private var cellularSessions: [PingSession] {
        sessions.filter { $0.networkType == .cellular && !$0.results.isEmpty }
    }

    private var wifiAvgLatency: Double? {
        let latencies = wifiSessions.compactMap { $0.avgLatency }
        guard !latencies.isEmpty else { return nil }
        return latencies.reduce(0, +) / Double(latencies.count)
    }

    private var cellularAvgLatency: Double? {
        let latencies = cellularSessions.compactMap { $0.avgLatency }
        guard !latencies.isEmpty else { return nil }
        return latencies.reduce(0, +) / Double(latencies.count)
    }

    private var wifiAvgPacketLoss: Double {
        guard !wifiSessions.isEmpty else { return 0 }
        let losses = wifiSessions.map { $0.packetLoss }
        return losses.reduce(0, +) / Double(losses.count)
    }

    private var cellularAvgPacketLoss: Double {
        guard !cellularSessions.isEmpty else { return 0 }
        let losses = cellularSessions.map { $0.packetLoss }
        return losses.reduce(0, +) / Double(losses.count)
    }

    private var wifiAvgScore: Int {
        let scores = wifiSessions.compactMap { $0.qualityScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    private var cellularAvgScore: Int {
        let scores = cellularSessions.compactMap { $0.qualityScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    private enum NetworkWinner {
        case wifi, cellular, tie, insufficientData
    }

    private var winner: NetworkWinner {
        guard !wifiSessions.isEmpty, !cellularSessions.isEmpty else {
            return .insufficientData
        }
        if wifiAvgScore > cellularAvgScore + 5 { return .wifi }
        if cellularAvgScore > wifiAvgScore + 5 { return .cellular }
        return .tie
    }

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(NetworkTheme.accent)
                    Text("WiFi vs Cellular")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(NetworkTheme.textPrimary)
                    Spacer()
                }

                if wifiSessions.isEmpty && cellularSessions.isEmpty {
                    Text("Monitor on both WiFi and Cellular to see comparison")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(NetworkTheme.textSecondary)
                } else {
                    comparisonContent
                }
            }
        }
    }

    private var comparisonContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                networkColumn(
                    icon: "wifi",
                    name: "WiFi",
                    sessionCount: wifiSessions.count,
                    avgLatency: wifiAvgLatency,
                    avgLoss: wifiAvgPacketLoss,
                    avgScore: wifiAvgScore,
                    isWinner: winner == .wifi
                )

                dividerLine

                networkColumn(
                    icon: "antenna.radiowaves.left.and.right",
                    name: "Cellular",
                    sessionCount: cellularSessions.count,
                    avgLatency: cellularAvgLatency,
                    avgLoss: cellularAvgPacketLoss,
                    avgScore: cellularAvgScore,
                    isWinner: winner == .cellular
                )
            }

            winnerBanner
        }
    }

    private func networkColumn(
        icon: String,
        name: String,
        sessionCount: Int,
        avgLatency: Double?,
        avgLoss: Double,
        avgScore: Int,
        isWinner: Bool
    ) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isWinner ? NetworkTheme.accentGreen : NetworkTheme.accent)

                Text(name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)
            }

            if sessionCount > 0 {
                VStack(spacing: 8) {
                    comparisonStat(
                        label: "Avg Ping",
                        value: avgLatency.map { String(format: "%.0f ms", $0) } ?? "--"
                    )
                    comparisonStat(
                        label: "Avg Loss",
                        value: String(format: "%.1f%%", avgLoss)
                    )
                    comparisonStat(
                        label: "Score",
                        value: avgScore > 0 ? "\(avgScore)" : "--"
                    )
                    Text("\(sessionCount) sessions")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                }
            } else {
                Text("No data yet")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(NetworkTheme.textTertiary)
                    .padding(.vertical, 20)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func comparisonStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(NetworkTheme.textPrimary)

            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(NetworkTheme.textTertiary)
        }
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(NetworkTheme.textTertiary.opacity(0.2))
            .frame(width: 1)
            .padding(.vertical, 4)
    }

    private var winnerBanner: some View {
        Group {
            switch winner {
            case .wifi:
                winnerLabel(text: "WiFi is performing better", icon: "wifi", color: NetworkTheme.accentGreen)
            case .cellular:
                winnerLabel(text: "Cellular is performing better", icon: "antenna.radiowaves.left.and.right", color: NetworkTheme.accentGreen)
            case .tie:
                winnerLabel(text: "Both networks are similar", icon: "equal.circle.fill", color: NetworkTheme.accent)
            case .insufficientData:
                winnerLabel(text: "Test both networks to compare", icon: "info.circle.fill", color: NetworkTheme.textTertiary)
            }
        }
    }

    private func winnerLabel(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)

            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
