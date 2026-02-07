import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PingSession.startTime, order: .reverse) private var sessions: [PingSession]

    var body: some View {
        ZStack {
            NetworkBackground()

            if sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("History")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)

                        NetworkComparisonView(sessions: sessions)
                            .padding(.horizontal)

                        LazyVStack(spacing: 12) {
                            ForEach(sessions) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionCard(session: session)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(NetworkTheme.textTertiary)

            Text("No History Yet")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(NetworkTheme.textPrimary)

            Text("Your monitoring sessions will appear here")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(NetworkTheme.textSecondary)
        }
    }
}

struct SessionCard: View {
    let session: PingSession

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    NetworkTypeIndicator(networkType: session.networkType)

                    if let score = session.qualityScore {
                        qualityBadge(score: score, tier: session.qualityResult.tier)
                    }

                    Spacer()

                    Text(session.startTime, format: .dateTime.month().day().hour().minute())
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(NetworkTheme.textSecondary)
                }

                Divider()
                    .background(NetworkTheme.textTertiary.opacity(0.2))

                HStack(spacing: 24) {
                    statItem(title: "Duration", value: session.formattedDuration)
                    statItem(title: "Avg Latency", value: session.avgLatency.map { String(format: "%.0f ms", $0) } ?? "--")
                    statItem(title: "Loss", value: String(format: "%.1f%%", session.packetLoss))
                }

                Text("Host: \(session.host)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(NetworkTheme.textTertiary)
            }
        }
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(NetworkTheme.textSecondary)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(NetworkTheme.textPrimary)
        }
    }

    private func qualityBadge(score: Int, tier: ConnectionQualityTier) -> some View {
        HStack(spacing: 6) {
            Text("\(score)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(tier.rawValue)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tierColor(tier))
        .clipShape(Capsule())
    }

    private func tierColor(_ tier: ConnectionQualityTier) -> Color {
        switch tier {
        case .excellent:
            return NetworkTheme.accentGreen
        case .good:
            return NetworkTheme.accent
        case .fair:
            return NetworkTheme.accentOrange
        case .poor:
            return NetworkTheme.accentRed
        }
    }
}
