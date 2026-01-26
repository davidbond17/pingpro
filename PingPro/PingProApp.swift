import SwiftUI
import SwiftData

@main
struct PingProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PingResult.self, PingSession.self])
    }
}
