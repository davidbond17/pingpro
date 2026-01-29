import SwiftUI
import Charts

struct PingChartView: View {
    let results: [PingResult]
    let avgLatency: Double?

    @State private var selectedTimestamp: Date?

    private var selectedResult: PingResult? {
        guard let timestamp = selectedTimestamp else { return nil }
        return results.first { result in
            abs(result.timestamp.timeIntervalSince(timestamp)) < 0.5
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !results.isEmpty {
                chartHeader
                chart
            } else {
                emptyState
            }
        }
    }

    private var chartHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Latency")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                if let selected = selectedResult {
                    Text(selected.latency?.asLatency ?? "Timeout")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.latencyColor(for: selected.latency))
                } else if let latest = results.last {
                    Text(latest.latency?.asLatency ?? "Timeout")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.latencyColor(for: latest.latency))
                }
            }

            Spacer()

            if let selected = selectedResult {
                Text(selected.timestamp, format: .dateTime.hour().minute().second())
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(NetworkTheme.textSecondary)
            }
        }
    }

    private var chart: some View {
        Chart {
            ForEach(results) { result in
                if let latency = result.latency {
                    LineMark(
                        x: .value("Time", result.timestamp),
                        y: .value("Latency", latency)
                    )
                    .foregroundStyle(Color.latencyColor(for: latency))
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Time", result.timestamp),
                        y: .value("Latency", latency)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.latencyColor(for: latency).opacity(0.3),
                                Color.latencyColor(for: latency).opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                } else {
                    PointMark(
                        x: .value("Time", result.timestamp),
                        y: .value("Latency", maxLatencyForScale)
                    )
                    .foregroundStyle(NetworkTheme.accentRed)
                    .symbol {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(NetworkTheme.accentRed)
                    }
                }
            }

            if let avg = avgLatency {
                RuleMark(y: .value("Average", avg))
                    .foregroundStyle(NetworkTheme.accent.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("AVG")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(NetworkTheme.accent)
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(NetworkTheme.textTertiary.opacity(0.2))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(NetworkTheme.textTertiary.opacity(0.2))

                AxisValueLabel {
                    if let ms = value.as(Double.self) {
                        Text("\(Int(ms))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(NetworkTheme.textSecondary)
                    }
                }
            }
        }
        .chartYScale(domain: 0...(maxLatencyForScale * 1.1))
        .chartXSelection(value: $selectedTimestamp)
        .frame(height: 220)
        .animation(.easeInOut(duration: 0.3), value: results.count)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(NetworkTheme.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [NetworkTheme.accent, NetworkTheme.accent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 6) {
                Text("No Data Yet")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                Text("Start monitoring to see live latency")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(NetworkTheme.textTertiary)
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }

    private var maxLatencyForScale: Double {
        let latencies = results.compactMap { $0.latency }
        guard !latencies.isEmpty else { return 100 }
        let max = latencies.max() ?? 100
        return Swift.max(max, 50)
    }
}

extension PingResult: Identifiable {}
