import SwiftUI

extension Color {
    static var theme: NetworkTheme.Type {
        NetworkTheme.self
    }

    static func latencyColor(for latency: Double?) -> Color {
        guard let ms = latency else {
            return NetworkTheme.accentRed
        }

        switch ms {
        case 0..<50:
            return NetworkTheme.accentGreen
        case 50..<100:
            return NetworkTheme.accent
        case 100..<200:
            return NetworkTheme.accentOrange
        default:
            return NetworkTheme.accentRed
        }
    }

    static func qualityColor(for quality: ConnectionQuality) -> Color {
        switch quality {
        case .excellent:
            return NetworkTheme.accentGreen
        case .good:
            return NetworkTheme.accent
        case .fair:
            return NetworkTheme.accentOrange
        case .poor:
            return NetworkTheme.accentRed
        }
    }
}

enum ConnectionQuality {
    case excellent
    case good
    case fair
    case poor

    init(latency: Double?) {
        guard let ms = latency else {
            self = .poor
            return
        }

        switch ms {
        case 0..<50:
            self = .excellent
        case 50..<100:
            self = .good
        case 100..<200:
            self = .fair
        default:
            self = .poor
        }
    }

    var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        }
    }
}
