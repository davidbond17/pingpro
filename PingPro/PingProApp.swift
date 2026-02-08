import SwiftUI
import SwiftData

@main
struct PingProApp: App {
    init() {
        BackgroundMonitorService.shared.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    BackgroundMonitorService.shared.scheduleBackgroundPing()
                }
        }
        .modelContainer(PersistenceManager.shared.container)
    }
}
