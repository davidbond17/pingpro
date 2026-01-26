import Foundation
import SwiftData

@Model
final class PingResult {
    var id: UUID
    var timestamp: Date
    var latency: Double?
    var host: String
    var networkType: NetworkType
    var didSucceed: Bool

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        latency: Double?,
        host: String,
        networkType: NetworkType,
        didSucceed: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.latency = latency
        self.host = host
        self.networkType = networkType
        self.didSucceed = didSucceed
    }

    var isTimeout: Bool {
        latency == nil
    }
}
