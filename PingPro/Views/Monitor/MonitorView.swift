import SwiftUI
import SwiftData

struct MonitorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: PingMonitorViewModel?

    var body: some View {
        ZStack {
            NetworkBackground()

            VStack(spacing: 0) {
                if let viewModel = viewModel {
                    headerSection(viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            QualityScoreView(
                                score: viewModel.qualityScore,
                                tier: viewModel.qualityTier
                            )
                            .padding(.horizontal, 20)

                            chartSection(viewModel: viewModel)
                                .padding(.horizontal, 20)

                            statsGrid(viewModel: viewModel)
                                .padding(.horizontal, 20)

                            qualityBadge(viewModel: viewModel)

                            NetworkExplainer(
                                avgLatency: viewModel.avgLatency,
                                packetLoss: viewModel.packetLoss
                            )
                            .padding(.horizontal, 20)

                            ActivityRecommendationsView(
                                avgLatency: viewModel.avgLatency,
                                packetLoss: viewModel.packetLoss
                            )
                            .padding(.horizontal, 20)

                            TroubleshootingView(
                                avgLatency: viewModel.avgLatency,
                                packetLoss: viewModel.packetLoss,
                                networkType: viewModel.currentNetworkType
                            )
                            .padding(.horizontal, 20)

                            controlButton(viewModel: viewModel)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PingMonitorViewModel(modelContext: modelContext)
            }
        }
        .onDisappear {
            viewModel?.cleanup()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background || scenePhase == .inactive {
                viewModel?.cleanup()
            }
        }
    }

    private func headerSection(viewModel: PingMonitorViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("PingPro")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Network Monitor")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(NetworkTheme.textSecondary)
            }

            Spacer()

            NetworkTypeIndicator(networkType: viewModel.currentNetworkType)
        }
    }

    private func chartSection(viewModel: PingMonitorViewModel) -> some View {
        GlassCard {
            PingChartView(
                results: viewModel.recentResults,
                avgLatency: viewModel.avgLatency
            )
        }
    }

    private func statsGrid(viewModel: PingMonitorViewModel) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 10) {
            StatsCardView(
                title: "Min",
                value: viewModel.minLatency.map { String(format: "%.0f", $0) } ?? "--",
                unit: "ms",
                color: NetworkTheme.accentGreen
            )

            StatsCardView(
                title: "Max",
                value: viewModel.maxLatency.map { String(format: "%.0f", $0) } ?? "--",
                unit: "ms",
                color: NetworkTheme.accentRed
            )

            StatsCardView(
                title: "Avg",
                value: viewModel.avgLatency.map { String(format: "%.0f", $0) } ?? "--",
                unit: "ms",
                color: NetworkTheme.accent
            )

            StatsCardView(
                title: "Loss",
                value: String(format: "%.1f", viewModel.packetLoss),
                unit: "%",
                color: NetworkTheme.accentOrange
            )
        }
    }

    private func qualityBadge(viewModel: PingMonitorViewModel) -> some View {
        Group {
            if let latency = viewModel.currentLatency {
                ConnectionQualityBadge(quality: ConnectionQuality(latency: latency))
            }
        }
    }

    private func controlButton(viewModel: PingMonitorViewModel) -> some View {
        Button(action: {
            if viewModel.isMonitoring {
                viewModel.stopMonitoring()
            } else {
                viewModel.startMonitoring()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: viewModel.isMonitoring ? [
                                NetworkTheme.accentRed,
                                NetworkTheme.accentRed.opacity(0.8)
                            ] : [
                                NetworkTheme.accentGreen,
                                NetworkTheme.accentGreen.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: (viewModel.isMonitoring ? NetworkTheme.accentRed : NetworkTheme.accentGreen).opacity(0.5), radius: 15, y: 8)

                HStack(spacing: 12) {
                    Image(systemName: viewModel.isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 28, weight: .semibold))

                    Text(viewModel.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
            }
            .frame(height: 56)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.isMonitoring)
    }
}
