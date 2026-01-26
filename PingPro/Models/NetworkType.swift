import Foundation

enum NetworkType: String, Codable {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case wired = "Wired"
    case unknown = "Unknown"

    var iconName: String {
        switch self {
        case .wifi:
            return "wifi"
        case .cellular:
            return "antenna.radiowaves.left.and.right"
        case .wired:
            return "cable.connector"
        case .unknown:
            return "questionmark.circle"
        }
    }
}
