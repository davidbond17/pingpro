import Foundation

struct NetworkActivity {
    let name: String
    let icon: String
    let maxLatency: Double
    let maxPacketLoss: Double
    let description: String
    let category: ActivityCategory
}

enum ActivityCategory {
    case gaming
    case streaming
    case communication
    case browsing
}

enum ActivityStatus {
    case excellent
    case good
    case poor
}

struct ActivityRecommendation {
    let activity: NetworkActivity
    let status: ActivityStatus
    let message: String
}

class ActivityRecommender {
    static let activities: [NetworkActivity] = [
        NetworkActivity(
            name: "Competitive Gaming",
            icon: "gamecontroller.fill",
            maxLatency: 30,
            maxPacketLoss: 0.5,
            description: "FPS, MOBA, fighting games",
            category: .gaming
        ),
        NetworkActivity(
            name: "Casual Gaming",
            icon: "gamecontroller",
            maxLatency: 80,
            maxPacketLoss: 2.0,
            description: "Turn-based, strategy games",
            category: .gaming
        ),
        NetworkActivity(
            name: "4K Streaming",
            icon: "4k.tv.fill",
            maxLatency: 50,
            maxPacketLoss: 1.0,
            description: "Ultra HD video content",
            category: .streaming
        ),
        NetworkActivity(
            name: "HD Streaming",
            icon: "tv.fill",
            maxLatency: 100,
            maxPacketLoss: 2.0,
            description: "1080p video content",
            category: .streaming
        ),
        NetworkActivity(
            name: "Video Calls",
            icon: "video.fill",
            maxLatency: 150,
            maxPacketLoss: 3.0,
            description: "Zoom, FaceTime, Teams",
            category: .communication
        ),
        NetworkActivity(
            name: "Voice Calls",
            icon: "phone.fill",
            maxLatency: 200,
            maxPacketLoss: 5.0,
            description: "Phone calls, Discord",
            category: .communication
        ),
        NetworkActivity(
            name: "Web Browsing",
            icon: "safari.fill",
            maxLatency: 300,
            maxPacketLoss: 10.0,
            description: "General internet usage",
            category: .browsing
        )
    ]

    static func getRecommendations(
        avgLatency: Double?,
        packetLoss: Double
    ) -> [ActivityRecommendation] {
        guard let latency = avgLatency else {
            return []
        }

        return activities.map { activity in
            let status = determineStatus(
                activity: activity,
                latency: latency,
                packetLoss: packetLoss
            )

            let message = generateMessage(
                activity: activity,
                status: status,
                latency: latency,
                packetLoss: packetLoss
            )

            return ActivityRecommendation(
                activity: activity,
                status: status,
                message: message
            )
        }
    }

    private static func determineStatus(
        activity: NetworkActivity,
        latency: Double,
        packetLoss: Double
    ) -> ActivityStatus {
        let latencyMargin = activity.maxLatency * 0.7
        let packetLossMargin = activity.maxPacketLoss * 0.7

        if latency <= latencyMargin && packetLoss <= packetLossMargin {
            return .excellent
        } else if latency <= activity.maxLatency && packetLoss <= activity.maxPacketLoss {
            return .good
        } else {
            return .poor
        }
    }

    private static func generateMessage(
        activity: NetworkActivity,
        status: ActivityStatus,
        latency: Double,
        packetLoss: Double
    ) -> String {
        switch status {
        case .excellent:
            return "Perfect connection"
        case .good:
            return "Should work well"
        case .poor:
            if latency > activity.maxLatency {
                return "Latency too high"
            } else {
                return "Too much packet loss"
            }
        }
    }

    static func getGoodActivities(
        avgLatency: Double?,
        packetLoss: Double
    ) -> [NetworkActivity] {
        let recommendations = getRecommendations(avgLatency: avgLatency, packetLoss: packetLoss)
        return recommendations
            .filter { $0.status == .excellent || $0.status == .good }
            .map { $0.activity }
    }

    static func getPoorActivities(
        avgLatency: Double?,
        packetLoss: Double
    ) -> [NetworkActivity] {
        let recommendations = getRecommendations(avgLatency: avgLatency, packetLoss: packetLoss)
        return recommendations
            .filter { $0.status == .poor }
            .map { $0.activity }
    }
}
