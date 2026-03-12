import SwiftUI
import Charts

/// 单只猫咪的体重折线图
struct WeightChartView: View {
    let kitten: Kitten

    private var records: [WeightRecord] {
        (kitten.weightRecords ?? []).sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体重趋势")
                .font(.headline)

            if records.isEmpty {
                ContentUnavailableView(
                    "暂无体重记录",
                    systemImage: "scalemass",
                    description: Text("添加体重记录后，趋势图将显示在这里")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(records, id: \.date) { record in
                        LineMark(
                            x: .value("日期", record.date),
                            y: .value("体重(g)", record.weight)
                        )
                        .foregroundStyle(AppColors.primary)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("日期", record.date),
                            y: .value("体重(g)", record.weight)
                        )
                        .foregroundStyle(record.weightStatus.color)
                        .symbolSize(30)
                    }

                    // 健康区间参考线
                    if let first = records.first, let last = records.last {
                        let startRange = WeightRange.range(forDayAge: first.dayAge)
                        let endRange = WeightRange.range(forDayAge: last.dayAge)

                        // 正常范围下限
                        LineMark(
                            x: .value("日期", first.date),
                            y: .value("正常低", startRange.normalLow)
                        )
                        .foregroundStyle(.green.opacity(0.3))
                        .lineStyle(StrokeStyle(dash: [5, 5]))

                        LineMark(
                            x: .value("日期", last.date),
                            y: .value("正常低", endRange.normalLow)
                        )
                        .foregroundStyle(.green.opacity(0.3))
                        .lineStyle(StrokeStyle(dash: [5, 5]))
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text(weight.weightText)
                                    .font(.caption2)
                            }
                        }
                    }
                }

                // 统计信息
                if records.count >= 2 {
                    statsRow
                }
            }
        }
        .padding()
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            if let first = records.first, let last = records.last {
                statItem(title: "初始", value: first.weight.weightText)
                statItem(title: "最新", value: last.weight.weightText)
                let gain = last.weight - first.weight
                statItem(title: "增长", value: "+\(gain.weightText)")
            }
        }
        .font(.caption)
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}
