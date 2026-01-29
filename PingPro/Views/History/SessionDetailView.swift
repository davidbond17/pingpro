import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: PingSession
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    header

                    GlassCard {
                        PingChartView(
                            results: session.results,
                            avgLatency: session.avgLatency
                        )
                    }

                    statsSection

                    deleteButton
                }
                .padding()
                .padding(.top)
        }
        .alert("Delete Session", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteSession()
            }
        } message: {
            Text("Are you sure you want to delete this session?")
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                NetworkTypeIndicator(networkType: session.networkType)

                Spacer()

                Text(session.startTime, format: .dateTime.month().day().year().hour().minute())
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(NetworkTheme.textSecondary)
            }

            Text("Host: \(session.host)")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(NetworkTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatsCardView(
                title: "Duration",
                value: session.formattedDuration,
                unit: "",
                color: NetworkTheme.accent
            )

            StatsCardView(
                title: "Pings",
                value: "\(session.results.count)",
                unit: "",
                color: NetworkTheme.accent
            )

            StatsCardView(
                title: "Min",
                value: session.minLatency.map { String(format: "%.0f", $0) } ?? "--",
                unit: "ms",
                color: NetworkTheme.accentGreen
            )

            StatsCardView(
                title: "Max",
                value: session.maxLatency.map { String(format: "%.0f", $0) } ?? "--",
                unit: "ms",
                color: NetworkTheme.accentRed
            )

            StatsCardView(
                title: "Avg",
                value: session.avgLatency.map { String(format: "%.0f", $0) } ?? "--",
                unit: "ms",
                color: NetworkTheme.accent
            )

            StatsCardView(
                title: "Loss",
                value: String(format: "%.1f", session.packetLoss),
                unit: "%",
                color: NetworkTheme.accentOrange
            )
        }
    }

    private var deleteButton: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Session")
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(NetworkTheme.accentRed)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func deleteSession() {
        modelContext.delete(session)
        try? modelContext.save()
        dismiss()
    }
}
