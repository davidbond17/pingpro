import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class PingMonitorViewModel {
    private(set) var isMonitoring = false
    private(set) var currentSession: PingSession?
    private(set) var recentResults: [PingResult] = []
    private(set) var currentNetworkType: NetworkType = .unknown

    var targetHost: String = AppSettings.targetHost
    var pingInterval: TimeInterval = AppSettings.pingInterval

    private(set) var minLatency: Double?
    private(set) var maxLatency: Double?
    private(set) var avgLatency: Double?
    private(set) var packetLoss: Double = 0.0
    private(set) var currentLatency: Double?
    private(set) var qualityScore: Int = 0
    private(set) var qualityTier: ConnectionQualityTier = .poor

    private var pingTask: Task<Void, Never>?
    private let networkMonitor: NetworkMonitor
    private let pingService: PingService
    private let modelContext: ModelContext
    private var previousNetworkType: NetworkType?
    private var previousQualityScore: Int = 0

    private let maxRecentResults = 60

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.networkMonitor = NetworkMonitor()
        self.pingService = PingService.shared
        self.currentNetworkType = networkMonitor.currentNetworkType

        fixOrphanedSessions()
    }

    private func fixOrphanedSessions() {
        let descriptor = FetchDescriptor<PingSession>(
            predicate: #Predicate { $0.endTime == nil }
        )

        if let orphanedSessions = try? modelContext.fetch(descriptor) {
            for session in orphanedSessions {
                if let lastResult = session.results.last {
                    session.endTime = lastResult.timestamp
                } else {
                    session.endTime = session.startTime
                }
            }

            try? modelContext.save()
        }
    }

    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        currentNetworkType = networkMonitor.currentNetworkType

        let session = PingSession(
            host: targetHost,
            networkType: currentNetworkType
        )
        currentSession = session
        modelContext.insert(session)

        recentResults.removeAll()
        resetStats()

        startPingLoop()
    }

    func stopMonitoring() {
        guard isMonitoring else { return }

        isMonitoring = false
        pingTask?.cancel()
        pingTask = nil

        if let session = currentSession {
            session.endTime = Date()
            session.qualityScore = qualityScore

            do {
                try modelContext.save()
            } catch {
                print("Failed to save session: \(error)")
            }
        }

        currentSession = nil
        recentResults.removeAll()
        resetStats()
    }

    func updateTargetHost(_ newHost: String) {
        targetHost = newHost
        AppSettings.targetHost = newHost
    }

    func updatePingInterval(_ newInterval: TimeInterval) {
        pingInterval = newInterval
        AppSettings.pingInterval = newInterval

        if isMonitoring {
            stopMonitoring()
            startMonitoring()
        }
    }

    private func startPingLoop() {
        pingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }

                self.currentNetworkType = self.networkMonitor.currentNetworkType

                await self.executePing()

                let interval = self.pingInterval
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    private func executePing() async {
        let result = await pingService.ping(
            host: targetHost,
            timeout: 5.0,
            networkType: currentNetworkType
        )

        guard let session = currentSession else { return }

        session.results.append(result)

        recentResults.append(result)
        if recentResults.count > maxRecentResults {
            recentResults.removeFirst()
        }

        updateStats()
    }

    private func updateStats() {
        let latencies = recentResults.compactMap { $0.latency }

        minLatency = latencies.min()
        maxLatency = latencies.max()

        if !latencies.isEmpty {
            avgLatency = latencies.reduce(0, +) / Double(latencies.count)
        } else {
            avgLatency = nil
        }

        if !recentResults.isEmpty {
            let failed = recentResults.filter { !$0.didSucceed }.count
            packetLoss = (Double(failed) / Double(recentResults.count)) * 100
        } else {
            packetLoss = 0
        }

        currentLatency = recentResults.last?.latency

        let qualityResult = ConnectionQualityCalculator.calculateScore(
            avgLatency: avgLatency,
            minLatency: minLatency,
            maxLatency: maxLatency,
            packetLoss: packetLoss
        )
        qualityScore = qualityResult.score
        qualityTier = qualityResult.tier

        checkAlerts()
    }

    private func checkAlerts() {
        let thresholds = AlertThresholds(
            latencyThreshold: AppSettings.latencyThreshold,
            packetLossThreshold: AppSettings.packetLossThreshold,
            isEnabled: AppSettings.alertsEnabled,
            alertOnNetworkChange: AppSettings.alertOnNetworkChange
        )

        ConnectionAlertManager.shared.checkThresholds(
            avgLatency: avgLatency,
            packetLoss: packetLoss,
            thresholds: thresholds
        )

        if let prevType = previousNetworkType,
           prevType != currentNetworkType,
           thresholds.alertOnNetworkChange {
            ConnectionAlertManager.shared.notifyNetworkChange(
                from: prevType,
                to: currentNetworkType
            )
        }
        previousNetworkType = currentNetworkType

        if qualityScore > previousQualityScore + 20 {
            ConnectionAlertManager.shared.notifyConnectionImproved(score: qualityScore)
        }
        previousQualityScore = qualityScore
    }

    private func resetStats() {
        minLatency = nil
        maxLatency = nil
        avgLatency = nil
        packetLoss = 0
        currentLatency = nil
    }

    func cleanup() {
        if isMonitoring {
            stopMonitoring()
        }
        pingTask?.cancel()
        networkMonitor.stopMonitoring()
    }
}
