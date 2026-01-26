import SwiftUI
import SwiftData

@main
struct PingProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceManager.shared.container)
    }
}
