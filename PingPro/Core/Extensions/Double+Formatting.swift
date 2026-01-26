import Foundation

extension Double {
    var asLatency: String {
        String(format: "%.1f ms", self)
    }

    var asLatencyShort: String {
        String(format: "%.0f", self)
    }

    var asPercentage: String {
        String(format: "%.1f%%", self)
    }
}

extension Optional where Wrapped == Double {
    var asLatencyOrTimeout: String {
        guard let value = self else {
            return "Timeout"
        }
        return value.asLatency
    }

    var asLatencyShortOrDash: String {
        guard let value = self else {
            return "--"
        }
        return value.asLatencyShort
    }
}
