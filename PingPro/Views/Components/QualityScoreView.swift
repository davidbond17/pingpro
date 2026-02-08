import SwiftUI

struct QualityScoreView: View {
    let score: Int
    let tier: ConnectionQualityTier
    let currentLatency: Double?
    let packetLoss: Double
    let isAnimated: Bool

    @State private var animatedScore: Double = 0

    init(
        score: Int,
        tier: ConnectionQualityTier,
        currentLatency: Double? = nil,
        packetLoss: Double = 0,
        isAnimated: Bool = true
    ) {
        self.score = score
        self.tier = tier
        self.currentLatency = currentLatency
        self.packetLoss = packetLoss
        self.isAnimated = isAnimated
    }

    var body: some View {
        HStack(spacing: 20) {
            scoreRing
            liveStats
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            tierColor.opacity(0.12),
                            tierColor.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            tierColor.opacity(0.4),
                            tierColor.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onAppear {
            if isAnimated {
                withAnimation(.spring(duration: 1.0)) {
                    animatedScore = Double(score)
                }
            } else {
                animatedScore = Double(score)
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.spring(duration: 0.5)) {
                animatedScore = Double(newValue)
            }
        }
    }

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(NetworkTheme.backgroundElevated, lineWidth: 10)
                .frame(width: 100, height: 100)

            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(
                        colors: [tierColor.opacity(0.6), tierColor],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedScore / 100)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 1.0), value: animatedScore)

            Circle()
                .fill(tierColor.opacity(0.08))
                .frame(width: 80, height: 80)

            VStack(spacing: 1) {
                Text("\(Int(animatedScore))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(tierColor)
                    .contentTransition(.numericText())

                Text(tier.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(tierColor.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .shadow(color: tierColor.opacity(0.3), radius: 12, y: 4)
    }

    private var liveStats: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let latency = currentLatency {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LIVE PING")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                        .tracking(1.5)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(String(format: "%.0f", latency))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.latencyColor(for: latency))
                            .contentTransition(.numericText())

                        Text("ms")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(NetworkTheme.textTertiary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PING")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                        .tracking(1.5)

                    Text("--")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(NetworkTheme.textTertiary)
                }
            }

            HStack(spacing: 12) {
                miniStat(label: "Loss", value: String(format: "%.1f%%", packetLoss),
                         color: packetLoss > 3 ? NetworkTheme.accentOrange : NetworkTheme.textSecondary)
            }
        }
    }

    private func miniStat(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(NetworkTheme.textTertiary)

            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
        }
    }

    private var tierColor: Color {
        switch tier {
        case .excellent: return NetworkTheme.accentGreen
        case .good: return NetworkTheme.accent
        case .fair: return NetworkTheme.accentOrange
        case .poor: return NetworkTheme.accentRed
        }
    }
}
