import Foundation
import SwiftData
import Observation

@Observable
final class KittenViewModel {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 删除猫咪及其所有关联数据
    func deleteKitten(_ kitten: Kitten) {
        modelContext.delete(kitten)
    }

    /// 获取排序后的健康记录
    func sortedHealthRecords(for kitten: Kitten) -> [HealthRecord] {
        (kitten.healthRecords ?? []).sorted { $0.date > $1.date }
    }

    /// 添加健康记录
    func addHealthRecord(
        to kitten: Kitten,
        type: HealthType,
        title: String,
        details: String,
        date: Date,
        reminderEnabled: Bool,
        reminderDate: Date?
    ) {
        let record = HealthRecord(
            healthType: type,
            title: title,
            details: details,
            date: date,
            reminderEnabled: reminderEnabled,
            reminderDate: reminderDate,
            kitten: kitten
        )
        modelContext.insert(record)
    }

    /// 删除健康记录
    func deleteHealthRecord(_ record: HealthRecord) {
        modelContext.delete(record)
    }
}
