import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]

    var body: some View {
        NavigationStack {
            Group {
                if kittens.isEmpty {
                    emptyState
                } else {
                    Text("今日时间线（待实现）")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("今日")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "暂无猫咪",
            systemImage: "cat",
            description: Text("请先在「猫咪」页面添加猫咪")
        )
    }
}
