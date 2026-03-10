import SwiftUI
import SwiftData

@main
struct MeowLogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Kitten.self,
            WeightRecord.self,
            FeedingLog.self,
            HealthRecord.self,
            KittenPhoto.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
