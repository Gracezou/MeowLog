import Foundation
import SwiftData

@Model
final class WeightRecord {
    /// 体重（克）
    var weight: Double
    var date: Date
    var notes: String

    var kitten: Kitten?

    init(weight: Double, date: Date = Date(), notes: String = "", kitten: Kitten? = nil) {
        self.weight = weight
        self.date = date
        self.notes = notes
        self.kitten = kitten
    }

    /// 该记录对应的日龄
    var dayAge: Int {
        guard let kitten else { return 0 }
        return DateHelpers.dayAge(from: kitten.birthDate, to: date)
    }

    /// 体重健康状态
    var weightStatus: WeightStatus {
        WeightRange.status(weight: weight, dayAge: dayAge)
    }
}
