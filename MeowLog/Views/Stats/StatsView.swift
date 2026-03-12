import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]
    @State private var selectedView = 0

    var body: some View {
        NavigationStack {
            Group {
                if kittens.isEmpty {
                    emptyState
                } else {
                    statsContent
                }
            }
            .navigationTitle("统计")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "暂无数据",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("添加猫咪并记录数据后，统计信息将显示在这里")
        )
    }

    // MARK: - Stats Content

    private var statsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 切换：体重对比 / 成长相册
                Picker("", selection: $selectedView) {
                    Text("体重对比").tag(0)
                    Text("成长相册").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if selectedView == 0 {
                    weightComparisonChart
                    dailyGainRanking
                } else {
                    PhotoGalleryView()
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Weight Comparison Chart

    private var weightComparisonChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体重对比")
                .font(.headline)
                .padding(.horizontal)

            let kittensWithRecords = kittens.filter { !($0.weightRecords ?? []).isEmpty }
            if kittensWithRecords.isEmpty {
                Text("暂无体重记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(kittensWithRecords) { kitten in
                        let records = (kitten.weightRecords ?? []).sorted { $0.date < $1.date }
                        ForEach(records, id: \.date) { record in
                            LineMark(
                                x: .value("日龄", record.dayAge),
                                y: .value("体重(g)", record.weight)
                            )
                            .foregroundStyle(by: .value("猫咪", kitten.name))
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("日龄", record.dayAge),
                                y: .value("体重(g)", record.weight)
                            )
                            .foregroundStyle(by: .value("猫咪", kitten.name))
                            .symbolSize(20)
                        }
                    }
                }
                .frame(height: 250)
                .chartXAxisLabel("日龄（天）")
                .chartYAxisLabel("体重（克）")
                .chartLegend(position: .bottom)
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Daily Gain Ranking

    private var dailyGainRanking: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日均增重排行")
                .font(.headline)
                .padding(.horizontal)

            let rankings = kittens.compactMap { kitten -> (kitten: Kitten, gain: Double)? in
                let vm = WeightViewModel(modelContext: modelContext)
                guard let gain = vm.dailyGain(for: kitten) else { return nil }
                return (kitten: kitten, gain: gain)
            }.sorted { $0.gain > $1.gain }

            if rankings.isEmpty {
                Text("需要至少 2 条体重记录才能计算")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(rankings, id: \.kitten.name) { item in
                    HStack(spacing: 12) {
                        KittenAvatarView(kitten: item.kitten, size: 36)
                        Text(item.kitten.name)
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "+%.1f g/天", item.gain))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(item.gain > 0 ? .green : .red)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal)
    }
}
