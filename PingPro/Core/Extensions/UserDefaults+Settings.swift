import Foundation
import SwiftUI

extension UserDefaults {
    enum Keys {
        static let targetHost = "targetHost"
        static let pingInterval = "pingInterval"
        static let networkPreference = "networkPreference"
        static let dataRetentionDays = "dataRetentionDays"
        static let alertsEnabled = "alertsEnabled"
        static let latencyThreshold = "latencyThreshold"
        static let packetLossThreshold = "packetLossThreshold"
        static let alertOnNetworkChange = "alertOnNetworkChange"
    }
}

enum NetworkPreference: String, CaseIterable {
    case auto = "Auto"
    case wifiOnly = "WiFi Only"
    case cellularOnly = "Cellular Only"

    var description: String {
        rawValue
    }
}

struct AppSettings {
    @AppStorage(UserDefaults.Keys.targetHost)
    static var targetHost: String = "8.8.8.8"

    @AppStorage(UserDefaults.Keys.pingInterval)
    static var pingInterval: Double = 1.0

    @AppStorage(UserDefaults.Keys.networkPreference)
    private static var networkPreferenceRaw: String = NetworkPreference.auto.rawValue

    static var networkPreference: NetworkPreference {
        get {
            NetworkPreference(rawValue: networkPreferenceRaw) ?? .auto
        }
        set {
            networkPreferenceRaw = newValue.rawValue
        }
    }

    @AppStorage(UserDefaults.Keys.dataRetentionDays)
    static var dataRetentionDays: Int = 30

    @AppStorage(UserDefaults.Keys.alertsEnabled)
    static var alertsEnabled: Bool = false

    @AppStorage(UserDefaults.Keys.latencyThreshold)
    static var latencyThreshold: Double = 150.0

    @AppStorage(UserDefaults.Keys.packetLossThreshold)
    static var packetLossThreshold: Double = 5.0

    @AppStorage(UserDefaults.Keys.alertOnNetworkChange)
    static var alertOnNetworkChange: Bool = true
}
