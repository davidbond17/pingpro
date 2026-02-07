import Foundation
import UserNotifications

enum AlertType {
    case latencyHigh
    case packetLossHigh
    case networkChanged
    case connectionImproved
}

struct AlertThresholds {
    var latencyThreshold: Double
    var packetLossThreshold: Double
    var isEnabled: Bool
    var alertOnNetworkChange: Bool
}

class ConnectionAlertManager {
    static let shared = ConnectionAlertManager()

    private var lastAlertTime: [AlertType: Date] = [:]
    private let debounceInterval: TimeInterval = 300
    private var hasPermission = false

    private init() {
        checkNotificationPermission()
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
                completion(granted)
            }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }

    func checkThresholds(
        avgLatency: Double?,
        packetLoss: Double,
        thresholds: AlertThresholds
    ) {
        guard thresholds.isEnabled, hasPermission else { return }

        if let latency = avgLatency, latency > thresholds.latencyThreshold {
            sendAlertIfNeeded(
                type: .latencyHigh,
                title: "High Latency Detected",
                body: "Your ping is \(Int(latency))ms (threshold: \(Int(thresholds.latencyThreshold))ms)"
            )
        }

        if packetLoss > thresholds.packetLossThreshold {
            sendAlertIfNeeded(
                type: .packetLossHigh,
                title: "Packet Loss Detected",
                body: "You're experiencing \(String(format: "%.1f", packetLoss))% packet loss"
            )
        }
    }

    func notifyNetworkChange(from oldType: NetworkType, to newType: NetworkType) {
        guard hasPermission else { return }

        sendAlertIfNeeded(
            type: .networkChanged,
            title: "Network Changed",
            body: "Switched from \(oldType.rawValue) to \(newType.rawValue)"
        )
    }

    func notifyConnectionImproved(score: Int) {
        guard hasPermission else { return }

        sendAlertIfNeeded(
            type: .connectionImproved,
            title: "Connection Improved",
            body: "Your quality score is now \(score)"
        )
    }

    private func sendAlertIfNeeded(type: AlertType, title: String, body: String) {
        if shouldSendAlert(type: type) {
            sendNotification(title: title, body: body)
            lastAlertTime[type] = Date()
        }
    }

    private func shouldSendAlert(type: AlertType) -> Bool {
        guard let lastTime = lastAlertTime[type] else {
            return true
        }

        let timeSinceLastAlert = Date().timeIntervalSince(lastTime)
        return timeSinceLastAlert >= debounceInterval
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
