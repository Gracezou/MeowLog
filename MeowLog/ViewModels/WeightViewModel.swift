import Foundation
import SwiftData
import Observation

@Observable
final class WeightViewModel {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 添加体重记录
    func addWeight(to kitten: Kitten, weight: Double, date: Date = Date(), notes: String = "") {
        let record = WeightRecord(weight: weight, date: date, notes: notes, kitten: kitten)
        modelContext.insert(record)
    }

    /// 删除体重记录
    func deleteWeight(_ record: WeightRecord) {
        modelContext.delete(record)
    }

    /// 检测体重异常（与上次相比变化超过 10%）
    func detectAnomaly(kitten: Kitten, newWeight: Double) -> String? {
        guard let last = kitten.latestWeight else { return nil }
        let change = abs(newWeight - last.weight) / last.weight
        if change > 0.1 {
            let direction = newWeight > last.weight ? "增加" : "减少"
            return "体重\(direction)了 \(String(format: "%.1f", change * 100))%，请注意观察"
        }
        return nil
    }

    /// 获取排序后的体重记录
    func sortedRecords(for kitten: Kitten) -> [WeightRecord] {
        kitten.weightRecords.sorted { $0.date < $1.date }
    }

    /// 每日增重（克/天）
    func dailyGain(for kitten: Kitten) -> Double? {
        let records = sortedRecords(for: kitten)
        guard records.count >= 2,
              let first = records.first,
              let last = records.last else { return nil }
        let days = DateHelpers.dayAge(from: first.date, to: last.date)
        guard days > 0 else { return nil }
        return (last.weight - first.weight) / Double(days)
    }
}
