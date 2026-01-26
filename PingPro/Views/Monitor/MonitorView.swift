import SwiftUI
import SwiftData

struct MonitorView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PingMonitorViewModel?

    var body: some View {
        ZStack {
            NetworkTheme.backgroundDeep
                .ignoresSafeArea()

            if let viewModel = viewModel {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection(viewModel: viewModel)

                        chartPlaceholder

                        statsGrid(viewModel: viewModel)

                        qualityBadge(viewModel: viewModel)
                    }
                    .padding()
                    .padding(.top)
                }

                VStack {
                    Spacer()
                    controlButton(viewModel: viewModel)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PingMonitorViewModel(modelContext: modelContext)
            }
        }
    }

    private func headerSection(viewModel: PingMonitorViewModel) -> some View {
        VStack(spacing: 12) {
            Text("PingPro")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            NetworkTypeIndicator(networkType: viewModel.currentNetworkType)
        }
    }

    private var chartPlaceholder: some View {
        GlassCard {
            VStack {
                Text("Chart")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textSecondary)

                Text("Coming in Phase 6")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(NetworkTheme.textTertiary)
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
        }
    }

    private func statsGrid(viewModel: PingMonitorViewModel) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
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
                viewModel.pauseMonitoring()
            } else {
                viewModel.startMonitoring()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isMonitoring ? "pause.fill" : "play.fill")
                    .font(.system(size: 24, weight: .bold))

                Text(viewModel.isMonitoring ? "Pause" : "Start")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: 200)
            .padding(.vertical, 18)
            .background(viewModel.isMonitoring ? NetworkTheme.accentOrange : NetworkTheme.accentGreen)
            .clipShape(Capsule())
            .shadow(color: (viewModel.isMonitoring ? NetworkTheme.accentOrange : NetworkTheme.accentGreen).opacity(0.4), radius: 20, y: 10)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.isMonitoring)
    }
}
