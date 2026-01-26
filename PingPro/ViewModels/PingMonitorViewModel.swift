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

    private var pingTask: Task<Void, Never>?
    private let networkMonitor: NetworkMonitor
    private let pingService: PingService
    private let modelContext: ModelContext

    private let maxRecentResults = 60

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.networkMonitor = NetworkMonitor()
        self.pingService = PingService.shared

        observeNetworkChanges()
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

    func pauseMonitoring() {
        guard isMonitoring else { return }

        isMonitoring = false
        pingTask?.cancel()
        pingTask = nil
    }

    func stopAndSaveSession() {
        guard let session = currentSession else { return }

        pauseMonitoring()

        session.endTime = Date()

        do {
            try modelContext.save()
        } catch {
            print("Failed to save session: \(error)")
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
            pauseMonitoring()
            startMonitoring()
        }
    }

    private func startPingLoop() {
        pingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.executePing()

                guard let interval = self?.pingInterval else { break }
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
    }

    private func resetStats() {
        minLatency = nil
        maxLatency = nil
        avgLatency = nil
        packetLoss = 0
        currentLatency = nil
    }

    private func observeNetworkChanges() {
        Task { [weak self] in
            while true {
                guard let self = self else { break }

                let newNetworkType = self.networkMonitor.currentNetworkType

                if self.isMonitoring && newNetworkType != self.currentNetworkType {
                    self.handleNetworkChange(to: newNetworkType)
                }

                self.currentNetworkType = newNetworkType

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    private func handleNetworkChange(to newType: NetworkType) {
        let preference = AppSettings.networkPreference

        switch preference {
        case .auto:
            currentNetworkType = newType
        case .wifiOnly:
            if newType != .wifi {
                pauseMonitoring()
            }
        case .cellularOnly:
            if newType != .cellular {
                pauseMonitoring()
            }
        }
    }

    func cleanup() {
        pingTask?.cancel()
        networkMonitor.stopMonitoring()
    }
}
