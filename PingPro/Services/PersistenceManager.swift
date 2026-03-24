import Foundation
import SwiftData

@MainActor
final class PersistenceManager {
    static let shared = PersistenceManager()

    let container: ModelContainer

    private init() {
        let schema = Schema([
            PingResult.self,
            PingSession.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // If the store is corrupted, attempt recovery with a fresh in-memory store
            // so the app doesn't crash. Data will be lost but user can continue.
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            do {
                container = try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Failed to create even an in-memory ModelContainer: \(error)")
            }
        }
    }
}
