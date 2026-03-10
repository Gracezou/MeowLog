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
        // CloudKit 自动同步：需要在 Xcode 中启用 iCloud capability
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
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
