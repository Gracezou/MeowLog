import Foundation
import SwiftData
import Observation

@Observable
final class FeedingViewModel {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 添加喂食记录
    func addFeeding(kittens: [Kitten], type: FeedingType, amount: Double, date: Date = Date(), notes: String = "") {
        let log = FeedingLog(feedingType: type, amount: amount, date: date, notes: notes, kittens: kittens)
        modelContext.insert(log)
    }

    /// 删除喂食记录
    func deleteFeeding(_ log: FeedingLog) {
        modelContext.delete(log)
    }

    /// 今日喂食总量（毫升）
    func todayTotalAmount(for kitten: Kitten) -> Double {
        let today = DateHelpers.startOfToday
        return kitten.feedingLogs
            .filter { $0.date >= today }
            .reduce(0) { $0 + $1.amount }
    }

    /// 今日喂食次数
    func todayFeedingCount(for kitten: Kitten) -> Int {
        let today = DateHelpers.startOfToday
        return kitten.feedingLogs.filter { $0.date >= today }.count
    }

    /// 获取今日所有喂食记录（按时间倒序）
    func todayFeedings(kittens: [Kitten]) -> [FeedingLog] {
        let today = DateHelpers.startOfToday
        let allLogs = Set(kittens.flatMap(\.feedingLogs))
        return allLogs
            .filter { $0.date >= today }
            .sorted { $0.date > $1.date }
    }
}
