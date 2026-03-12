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

        // 优先尝试 CloudKit 同步，失败时降级为本地存储
        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        if let container = try? ModelContainer(for: schema, configurations: [cloudConfig]) {
            return container
        }

        // CloudKit 容器未就绪（如首次运行、未登录 iCloud），回退到本地存储
        let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [localConfig])
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
