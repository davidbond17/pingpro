import Foundation
import BackgroundTasks
import SwiftData
import Network

final class BackgroundMonitorService {
    static let shared = BackgroundMonitorService()
    static let taskIdentifier = "com.portfolio.vibe.PingPro.backgroundPing"

    private let pingCount = 5

    private init() {}

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleBackgroundPing(task: refreshTask)
        }
    }

    func scheduleBackgroundPing() {
        let enabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.backgroundMonitoringEnabled)
        guard enabled else { return }

        let interval = UserDefaults.standard.double(forKey: UserDefaults.Keys.backgroundMonitoringInterval)
        let minuteInterval = interval > 0 ? interval : 15.0

        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: minuteInterval * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background ping: \(error)")
        }
    }

    func cancelScheduledTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)
    }

    private func handleBackgroundPing(task: BGAppRefreshTask) {
        scheduleBackgroundPing()

        let pingTask = Task {
            await self.performBackgroundPings()
        }

        task.expirationHandler = {
            pingTask.cancel()
        }

        Task {
            await pingTask.value
            task.setTaskCompleted(success: true)
        }
    }

    private func performBackgroundPings() async {
        let networkType = await detectNetworkType()

        let wifiOnly = UserDefaults.standard.bool(forKey: UserDefaults.Keys.backgroundMonitoringWiFiOnly)
        if wifiOnly && networkType != .wifi {
            return
        }

        let host = UserDefaults.standard.string(forKey: UserDefaults.Keys.targetHost) ?? "8.8.8.8"

        var pingData: [(latency: Double?, didSucceed: Bool)] = []

        for i in 0..<pingCount {
            if Task.isCancelled { break }

            let result = await PingService.shared.ping(
                host: host,
                timeout: 5.0,
                networkType: networkType
            )
            pingData.append((latency: result.latency, didSucceed: result.didSucceed))

            if i < pingCount - 1 {
                try? await Task.sleep(for: .seconds(1))
            }
        }

        guard !pingData.isEmpty else { return }

        await saveBackgroundSession(
            host: host,
            networkType: networkType,
            pingData: pingData
        )
    }

    private func detectNetworkType() async -> NetworkType {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "bg.network.check")
            monitor.pathUpdateHandler = { path in
                monitor.cancel()
                if path.usesInterfaceType(.wifi) {
                    continuation.resume(returning: .wifi)
                } else if path.usesInterfaceType(.cellular) {
                    continuation.resume(returning: .cellular)
                } else if path.usesInterfaceType(.wiredEthernet) {
                    continuation.resume(returning: .wired)
                } else {
                    continuation.resume(returning: .unknown)
                }
            }
            monitor.start(queue: queue)
        }
    }

    @MainActor
    private func saveBackgroundSession(
        host: String,
        networkType: NetworkType,
        pingData: [(latency: Double?, didSucceed: Bool)]
    ) {
        let container = PersistenceManager.shared.container
        let context = ModelContext(container)

        let session = PingSession(
            host: host,
            networkType: networkType,
            isBackgroundSession: true
        )
        context.insert(session)

        let now = Date()
        let sessionStart = now.addingTimeInterval(-Double(pingData.count))

        for (index, ping) in pingData.enumerated() {
            let result = PingResult(
                timestamp: sessionStart.addingTimeInterval(Double(index)),
                latency: ping.latency,
                host: host,
                networkType: networkType,
                didSucceed: ping.didSucceed
            )
            context.insert(result)
            session.results.append(result)
        }

        session.startTime = sessionStart
        session.endTime = now
        session.qualityScore = session.qualityResult.score

        try? context.save()
    }
}
