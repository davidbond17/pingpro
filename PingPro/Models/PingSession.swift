import Foundation
import SwiftData

@Model
final class PingSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var host: String
    var networkType: NetworkType
    var qualityScore: Int?
    var isBackgroundSession: Bool = false

    @Relationship(deleteRule: .cascade)
    var results: [PingResult]

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        host: String,
        networkType: NetworkType,
        qualityScore: Int? = nil,
        isBackgroundSession: Bool = false,
        results: [PingResult] = []
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.host = host
        self.networkType = networkType
        self.qualityScore = qualityScore
        self.isBackgroundSession = isBackgroundSession
        self.results = results
    }

    var minLatency: Double? {
        results.compactMap { $0.latency }.min()
    }

    var maxLatency: Double? {
        results.compactMap { $0.latency }.max()
    }

    var avgLatency: Double? {
        let latencies = results.compactMap { $0.latency }
        guard !latencies.isEmpty else { return nil }
        return latencies.reduce(0, +) / Double(latencies.count)
    }

    var packetLoss: Double {
        guard !results.isEmpty else { return 0 }
        let failed = results.filter { !$0.didSucceed }.count
        return (Double(failed) / Double(results.count)) * 100
    }

    var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var qualityResult: ConnectionQualityResult {
        ConnectionQualityCalculator.calculateScore(
            avgLatency: avgLatency,
            minLatency: minLatency,
            maxLatency: maxLatency,
            packetLoss: packetLoss
        )
    }
}
