import SwiftUI

struct InsightsView: View {
    let sessions: [PingSession]

    private var insights: [ConnectionInsight] {
        InsightsEngine.generateInsights(from: sessions)
    }

    private var timeBreakdown: [TimeOfDayBreakdown] {
        InsightsEngine.getTimeOfDayBreakdown(from: sessions)
    }

    var body: some View {
        if sessions.count >= 2 {
            VStack(spacing: 16) {
                if !insights.isEmpty {
                    insightsSection
                }

                let periodsWithData = timeBreakdown.filter { $0.sessionCount > 0 }
                if periodsWithData.count >= 2 {
                    timeOfDaySection
                }
            }
        }
    }

    private var insightsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(NetworkTheme.accentYellow)
                    Text("Insights")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(NetworkTheme.textPrimary)
                }

                ForEach(insights) { insight in
                    insightRow(insight)
                }
            }
        }
    }

    private func insightRow(_ insight: ConnectionInsight) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.icon)
                .font(.system(size: 20))
                .foregroundStyle(colorForInsight(insight.color))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                Text(insight.description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(NetworkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }

    private var timeOfDaySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(NetworkTheme.accent)
                    Text("Time of Day")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(NetworkTheme.textPrimary)
                }

                let periodsWithData = timeBreakdown.filter { $0.sessionCount > 0 }

                ForEach(periodsWithData) { period in
                    timeRow(period)
                }
            }
        }
    }

    private func timeRow(_ period: TimeOfDayBreakdown) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(period.period)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                Text(period.hourRange)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(NetworkTheme.textTertiary)
            }

            Spacer()

            if let latency = period.avgLatency {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(latency))ms")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(NetworkTheme.textPrimary)

                    Text("avg ping")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                }
                .frame(width: 70)
            }

            if period.avgScore > 0 {
                scoreBar(score: period.avgScore)
            }
        }
        .padding(.vertical, 4)
    }

    private func scoreBar(score: Int) -> some View {
        HStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(NetworkTheme.backgroundElevated)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(scoreColor(score))
                        .frame(width: geometry.size.width * CGFloat(score) / 100.0)
                }
            }
            .frame(width: 50, height: 6)

            Text("\(score)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(scoreColor(score))
                .frame(width: 28, alignment: .trailing)
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return NetworkTheme.accentGreen }
        if score >= 60 { return NetworkTheme.accent }
        if score >= 40 { return NetworkTheme.accentOrange }
        return NetworkTheme.accentRed
    }

    private func colorForInsight(_ color: InsightColor) -> Color {
        switch color {
        case .green: return NetworkTheme.accentGreen
        case .blue: return NetworkTheme.accent
        case .orange: return NetworkTheme.accentOrange
        case .red: return NetworkTheme.accentRed
        }
    }
}
