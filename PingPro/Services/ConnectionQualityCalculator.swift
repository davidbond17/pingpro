import Foundation

enum ConnectionQualityTier: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    var color: String {
        switch self {
        case .excellent: return "accentGreen"
        case .good: return "accent"
        case .fair: return "accentOrange"
        case .poor: return "accentRed"
        }
    }
}

struct ConnectionQualityResult {
    let score: Int
    let tier: ConnectionQualityTier
    let breakdown: QualityBreakdown
}

struct QualityBreakdown {
    let latencyScore: Int
    let packetLossScore: Int
    let stabilityScore: Int
}

class ConnectionQualityCalculator {
    static func calculateScore(
        avgLatency: Double?,
        minLatency: Double?,
        maxLatency: Double?,
        packetLoss: Double
    ) -> ConnectionQualityResult {
        var totalScore = 100

        let latencyScore = calculateLatencyScore(avgLatency)
        totalScore -= (100 - latencyScore)

        let packetLossScore = calculatePacketLossScore(packetLoss)
        totalScore -= (100 - packetLossScore)

        let stabilityScore = calculateStabilityScore(min: minLatency, max: maxLatency, avg: avgLatency)
        totalScore -= (100 - stabilityScore)

        totalScore = max(0, min(100, totalScore))

        let tier = determineTier(score: totalScore)

        let breakdown = QualityBreakdown(
            latencyScore: latencyScore,
            packetLossScore: packetLossScore,
            stabilityScore: stabilityScore
        )

        return ConnectionQualityResult(score: totalScore, tier: tier, breakdown: breakdown)
    }

    private static func calculateLatencyScore(_ avgLatency: Double?) -> Int {
        guard let latency = avgLatency else { return 0 }

        if latency < 20 {
            return 100
        } else if latency < 50 {
            return 90
        } else if latency < 100 {
            return 75
        } else if latency < 150 {
            return 60
        } else if latency < 200 {
            return 40
        } else if latency < 300 {
            return 20
        } else {
            return 5
        }
    }

    private static func calculatePacketLossScore(_ packetLoss: Double) -> Int {
        if packetLoss < 0.5 {
            return 100
        } else if packetLoss < 1 {
            return 95
        } else if packetLoss < 2 {
            return 85
        } else if packetLoss < 5 {
            return 70
        } else if packetLoss < 10 {
            return 50
        } else if packetLoss < 20 {
            return 30
        } else {
            return 10
        }
    }

    private static func calculateStabilityScore(min: Double?, max: Double?, avg: Double?) -> Int {
        guard let minLatency = min,
              let maxLatency = max,
              let avgLatency = avg,
              avgLatency > 0 else {
            return 100
        }

        let jitter = maxLatency - minLatency
        let jitterRatio = jitter / avgLatency

        if jitterRatio < 0.1 {
            return 100
        } else if jitterRatio < 0.2 {
            return 95
        } else if jitterRatio < 0.5 {
            return 85
        } else if jitterRatio < 1.0 {
            return 70
        } else if jitterRatio < 2.0 {
            return 50
        } else {
            return 30
        }
    }

    private static func determineTier(score: Int) -> ConnectionQualityTier {
        if score >= 80 {
            return .excellent
        } else if score >= 60 {
            return .good
        } else if score >= 40 {
            return .fair
        } else {
            return .poor
        }
    }
}
