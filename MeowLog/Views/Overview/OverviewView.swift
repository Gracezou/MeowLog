import SwiftUI
import SwiftData

struct OverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: AppConstants.gridColumns)

    var body: some View {
        NavigationStack {
            ScrollView {
                if kittens.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 20) {
                        // 里程碑进度（取第一只猫的日龄作为代表）
                        if let firstKitten = kittens.first {
                            MilestoneProgressView(dayAge: firstKitten.dayAge)
                                .padding(.horizontal)
                        }

                        // 9 宫格
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(kittens) { kitten in
                                NavigationLink(value: kitten) {
                                    KittenGridCell(kitten: kitten)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        // 今日摘要
                        todaySummary
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("MeowLog")
            .navigationDestination(for: Kitten.self) { kitten in
                KittenDetailView(kitten: kitten)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("还没有猫咪", systemImage: "cat")
        } description: {
            Text("点击「猫咪」标签页添加你的第一只小猫")
        }
        .padding(.top, 100)
    }

    // MARK: - Today Summary

    private var todaySummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日概况")
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 16) {
                summaryCard(
                    title: "已称重",
                    value: "\(weighedTodayCount)/\(kittens.count)",
                    icon: "scalemass.fill",
                    color: AppColors.primary
                )
                summaryCard(
                    title: "已喂食",
                    value: "\(fedTodayCount)次",
                    icon: "drop.fill",
                    color: AppColors.secondary
                )
            }
            .padding(.horizontal)
        }
    }

    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Computed

    private var weighedTodayCount: Int {
        kittens.filter { kitten in
            kitten.weightRecords.contains { $0.date.isToday }
        }.count
    }

    private var fedTodayCount: Int {
        let today = DateHelpers.startOfToday
        return kittens.flatMap(\.feedingLogs).filter { $0.date >= today }.count
    }
}
