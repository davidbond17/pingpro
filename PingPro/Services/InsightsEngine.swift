import Foundation

struct ConnectionInsight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: InsightColor
}

enum InsightColor {
    case green, blue, orange, red
}

struct TimeOfDayBreakdown: Identifiable {
    let id = UUID()
    let period: String
    let hourRange: String
    let avgLatency: Double?
    let avgScore: Int
    let sessionCount: Int
}

class InsightsEngine {
    static func generateInsights(from sessions: [PingSession]) -> [ConnectionInsight] {
        guard !sessions.isEmpty else { return [] }

        var insights: [ConnectionInsight] = []

        if let scoreTrend = calculateScoreTrend(from: sessions) {
            insights.append(scoreTrend)
        }

        if let avgInsight = calculateOverallAverage(from: sessions) {
            insights.append(avgInsight)
        }

        if let bestTime = findBestTimeOfDay(from: sessions) {
            insights.append(bestTime)
        }

        if let networkInsight = compareNetworkTypes(from: sessions) {
            insights.append(networkInsight)
        }

        if let consistencyInsight = calculateConsistency(from: sessions) {
            insights.append(consistencyInsight)
        }

        return insights
    }

    static func getTimeOfDayBreakdown(from sessions: [PingSession]) -> [TimeOfDayBreakdown] {
        let periods: [(String, String, ClosedRange<Int>)] = [
            ("Morning", "6am - 12pm", 6...11),
            ("Afternoon", "12pm - 6pm", 12...17),
            ("Evening", "6pm - 12am", 18...23),
            ("Night", "12am - 6am", 0...5)
        ]

        return periods.map { name, range, hours in
            let periodSessions = sessions.filter { session in
                let hour = Calendar.current.component(.hour, from: session.startTime)
                return hours.contains(hour)
            }

            let latencies = periodSessions.compactMap { $0.avgLatency }
            let avgLatency = latencies.isEmpty ? nil : latencies.reduce(0, +) / Double(latencies.count)

            let scores = periodSessions.compactMap { $0.qualityScore }
            let avgScore = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count

            return TimeOfDayBreakdown(
                period: name,
                hourRange: range,
                avgLatency: avgLatency,
                avgScore: avgScore,
                sessionCount: periodSessions.count
            )
        }
    }

    private static func calculateScoreTrend(from sessions: [PingSession]) -> ConnectionInsight? {
        let calendar = Calendar.current
        let now = Date()

        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now),
              let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) else {
            return nil
        }

        let thisWeekSessions = sessions.filter { $0.startTime >= oneWeekAgo }
        let lastWeekSessions = sessions.filter { $0.startTime >= twoWeeksAgo && $0.startTime < oneWeekAgo }

        let thisWeekScores = thisWeekSessions.compactMap { $0.qualityScore }
        let lastWeekScores = lastWeekSessions.compactMap { $0.qualityScore }

        guard !thisWeekScores.isEmpty else { return nil }

        let thisWeekAvg = thisWeekScores.reduce(0, +) / thisWeekScores.count

        if lastWeekScores.isEmpty {
            return ConnectionInsight(
                icon: "chart.line.uptrend.xyaxis",
                title: "Average Score: \(thisWeekAvg)",
                description: "Based on \(thisWeekScores.count) sessions this week",
                color: thisWeekAvg >= 80 ? .green : thisWeekAvg >= 60 ? .blue : .orange
            )
        }

        let lastWeekAvg = lastWeekScores.reduce(0, +) / lastWeekScores.count
        let difference = thisWeekAvg - lastWeekAvg

        if difference > 5 {
            return ConnectionInsight(
                icon: "arrow.up.right.circle.fill",
                title: "Improving by \(difference) Points",
                description: "Your connection quality improved from \(lastWeekAvg) to \(thisWeekAvg) this week",
                color: .green
            )
        } else if difference < -5 {
            return ConnectionInsight(
                icon: "arrow.down.right.circle.fill",
                title: "Declining by \(abs(difference)) Points",
                description: "Your connection quality dropped from \(lastWeekAvg) to \(thisWeekAvg) this week",
                color: .red
            )
        } else {
            return ConnectionInsight(
                icon: "equal.circle.fill",
                title: "Stable at \(thisWeekAvg) Points",
                description: "Your connection quality has been consistent this week",
                color: .blue
            )
        }
    }

    private static func calculateOverallAverage(from sessions: [PingSession]) -> ConnectionInsight? {
        let latencies = sessions.compactMap { $0.avgLatency }
        guard !latencies.isEmpty else { return nil }

        let avgLatency = latencies.reduce(0, +) / Double(latencies.count)
        let losses = sessions.map { $0.packetLoss }
        let avgLoss = losses.reduce(0, +) / Double(losses.count)

        return ConnectionInsight(
            icon: "gauge.with.needle.fill",
            title: "Average Ping: \(Int(avgLatency))ms",
            description: "Across \(sessions.count) sessions with \(String(format: "%.1f", avgLoss))% average packet loss",
            color: avgLatency < 50 ? .green : avgLatency < 100 ? .blue : .orange
        )
    }

    private static func findBestTimeOfDay(from sessions: [PingSession]) -> ConnectionInsight? {
        let breakdown = getTimeOfDayBreakdown(from: sessions)
        let withData = breakdown.filter { $0.sessionCount > 0 && $0.avgScore > 0 }

        guard withData.count >= 2,
              let best = withData.max(by: { $0.avgScore < $1.avgScore }) else {
            return nil
        }

        return ConnectionInsight(
            icon: "clock.fill",
            title: "Best Time: \(best.period)",
            description: "Your connection performs best during \(best.hourRange) (score: \(best.avgScore))",
            color: .green
        )
    }

    private static func compareNetworkTypes(from sessions: [PingSession]) -> ConnectionInsight? {
        let wifiSessions = sessions.filter { $0.networkType == .wifi }
        let cellularSessions = sessions.filter { $0.networkType == .cellular }

        guard !wifiSessions.isEmpty, !cellularSessions.isEmpty else { return nil }

        let wifiLatencies = wifiSessions.compactMap { $0.avgLatency }
        let cellularLatencies = cellularSessions.compactMap { $0.avgLatency }

        guard !wifiLatencies.isEmpty, !cellularLatencies.isEmpty else { return nil }

        let wifiAvg = wifiLatencies.reduce(0, +) / Double(wifiLatencies.count)
        let cellularAvg = cellularLatencies.reduce(0, +) / Double(cellularLatencies.count)

        if wifiAvg < cellularAvg {
            let difference = Int(cellularAvg - wifiAvg)
            return ConnectionInsight(
                icon: "wifi",
                title: "WiFi is \(difference)ms Faster",
                description: "WiFi averages \(Int(wifiAvg))ms vs Cellular at \(Int(cellularAvg))ms",
                color: .blue
            )
        } else {
            let difference = Int(wifiAvg - cellularAvg)
            return ConnectionInsight(
                icon: "antenna.radiowaves.left.and.right",
                title: "Cellular is \(difference)ms Faster",
                description: "Cellular averages \(Int(cellularAvg))ms vs WiFi at \(Int(wifiAvg))ms",
                color: .blue
            )
        }
    }

    private static func calculateConsistency(from sessions: [PingSession]) -> ConnectionInsight? {
        let scores = sessions.compactMap { $0.qualityScore }
        guard scores.count >= 3 else { return nil }

        let avg = Double(scores.reduce(0, +)) / Double(scores.count)
        let variance = scores.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(scores.count)
        let stdDev = sqrt(variance)

        if stdDev < 10 {
            return ConnectionInsight(
                icon: "checkmark.seal.fill",
                title: "Very Consistent Connection",
                description: "Your quality score only varies by \(Int(stdDev)) points between sessions",
                color: .green
            )
        } else if stdDev < 20 {
            return ConnectionInsight(
                icon: "waveform.path",
                title: "Moderately Consistent",
                description: "Your quality varies by about \(Int(stdDev)) points between sessions",
                color: .blue
            )
        } else {
            return ConnectionInsight(
                icon: "exclamationmark.triangle.fill",
                title: "Inconsistent Connection",
                description: "Your quality varies widely (\(Int(stdDev)) point swings) - consider investigating",
                color: .orange
            )
        }
    }
}
