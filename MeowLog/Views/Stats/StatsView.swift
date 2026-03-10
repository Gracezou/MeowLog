import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]

    var body: some View {
        NavigationStack {
            Group {
                if kittens.isEmpty {
                    emptyState
                } else {
                    Text("统计图表（待实现）")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("统计")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "暂无数据",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("添加猫咪并记录数据后，统计信息将显示在这里")
        )
    }
}
