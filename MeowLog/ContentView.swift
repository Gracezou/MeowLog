import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("总览", systemImage: "square.grid.3x3.fill", value: 0) {
                OverviewView()
            }

            Tab("猫咪", systemImage: "cat.fill", value: 1) {
                KittenListView()
            }

            Tab("今日", systemImage: "calendar", value: 2) {
                TodayView()
            }

            Tab("统计", systemImage: "chart.line.uptrend.xyaxis", value: 3) {
                StatsView()
            }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Kitten.self, WeightRecord.self, FeedingLog.self, HealthRecord.self, KittenPhoto.self], inMemory: true)
}
