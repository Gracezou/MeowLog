import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]

    @State private var showAddWeight = false
    @State private var showAddFeeding = false

    var body: some View {
        NavigationStack {
            Group {
                if kittens.isEmpty {
                    emptyState
                } else {
                    todayContent
                }
            }
            .navigationTitle("今日")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showAddWeight = true
                        } label: {
                            Label("记录体重", systemImage: "scalemass.fill")
                        }
                        Button {
                            showAddFeeding = true
                        } label: {
                            Label("记录喂食", systemImage: "drop.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddWeight) {
                AddWeightView()
            }
            .sheet(isPresented: $showAddFeeding) {
                AddFeedingView()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "暂无猫咪",
            systemImage: "cat",
            description: Text("请先在「猫咪」页面添加猫咪")
        )
    }

    // MARK: - Today Content

    private var todayContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 未称重提示
                unwieghedAlert

                // 今日统计
                todayStats

                // 喂食时间线
                feedingTimeline
            }
            .padding()
        }
    }

    // MARK: - Unweighed Alert

    private var unwieghedAlert: some View {
        let unweighed = kittens.filter { kitten in
            !(kitten.weightRecords ?? []).contains { $0.date.isToday }
        }
        return Group {
            if !unweighed.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("\(unweighed.count) 只猫咪今日未称重", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(unweighed) { kitten in
                                Button {
                                    showAddWeight = true
                                } label: {
                                    HStack(spacing: 4) {
                                        KittenAvatarView(kitten: kitten, size: 24)
                                        Text(kitten.name)
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Today Stats

    private var todayStats: some View {
        let vm = FeedingViewModel(modelContext: modelContext)
        return HStack(spacing: 12) {
            ForEach(kittens) { kitten in
                VStack(spacing: 4) {
                    KittenAvatarView(kitten: kitten, size: 36)
                    Text("\(vm.todayFeedingCount(for: kitten))次")
                        .font(.caption2)
                    Text(String(format: "%.0fml", vm.todayTotalAmount(for: kitten)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Feeding Timeline

    private var feedingTimeline: some View {
        let vm = FeedingViewModel(modelContext: modelContext)
        let todayLogs = vm.todayFeedings(kittens: kittens)

        return VStack(alignment: .leading, spacing: 12) {
            Text("喂食记录")
                .font(.headline)

            if todayLogs.isEmpty {
                Text("今日暂无喂食记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(todayLogs, id: \.date) { log in
                    feedingRow(log)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func feedingRow(_ log: FeedingLog) -> some View {
        HStack(spacing: 12) {
            Image(systemName: log.feedingType.icon)
                .font(.title3)
                .foregroundStyle(AppColors.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.feedingType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    ForEach((log.kittens ?? [])) { kitten in
                        Text(kitten.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.kittenColors[kitten.colorIndex].opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(DateHelpers.timeOnly(log.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f ml", log.amount))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}
