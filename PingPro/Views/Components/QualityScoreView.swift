import SwiftUI

struct QualityScoreView: View {
    let score: Int
    let tier: ConnectionQualityTier
    let isAnimated: Bool

    @State private var animatedScore: Double = 0

    init(score: Int, tier: ConnectionQualityTier, isAnimated: Bool = true) {
        self.score = score
        self.tier = tier
        self.isAnimated = isAnimated
    }

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("Connection Quality")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textSecondary)

                ZStack {
                    Circle()
                        .stroke(NetworkTheme.backgroundElevated, lineWidth: 12)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: animatedScore / 100)
                        .stroke(
                            tierColor,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 1.0), value: animatedScore)

                    VStack(spacing: 4) {
                        Text("\(Int(animatedScore))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(tierColor)
                            .contentTransition(.numericText())

                        Text(tier.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(NetworkTheme.textSecondary)
                    }
                }

                HStack(spacing: 20) {
                    scoreIndicator(label: "Min", value: "0", color: NetworkTheme.accentRed)
                    scoreIndicator(label: "Target", value: "80", color: NetworkTheme.accent)
                    scoreIndicator(label: "Max", value: "100", color: NetworkTheme.accentGreen)
                }
                .font(.system(size: 11, design: .rounded))
            }
        }
        .onAppear {
            if isAnimated {
                withAnimation(.spring(duration: 1.0)) {
                    animatedScore = Double(score)
                }
            } else {
                animatedScore = Double(score)
            }
        }
        .onChange(of: score) { oldValue, newValue in
            withAnimation(.spring(duration: 0.5)) {
                animatedScore = Double(newValue)
            }
        }
    }

    private var tierColor: Color {
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

    private func scoreIndicator(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(NetworkTheme.textPrimary)

            Text(label)
                .foregroundStyle(NetworkTheme.textTertiary)
        }
    }
}
