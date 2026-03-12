import Foundation
import SwiftData

// MARK: - Feeding Type

enum FeedingType: String, Codable, CaseIterable, Identifiable {
    case bottle = "奶瓶"
    case syringe = "针管"
    case naturalNursing = "母乳"
    case wetFood = "湿粮"
    case dryFood = "干粮"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bottle: return "drop.fill"
        case .syringe: return "syringe"
        case .naturalNursing: return "heart.fill"
        case .wetFood: return "fork.knife"
        case .dryFood: return "circle.grid.3x3.fill"
        }
    }
}

// MARK: - Feeding Log Model

@Model
final class FeedingLog {
    var feedingType: FeedingType = FeedingType.bottle
    /// 喂食量（毫升）
    var amount: Double = 0.0
    var date: Date = Date()
    var notes: String = ""

    /// 多对多：一次喂食可能涉及多只猫
    var kittens: [Kitten] = []

    init(
        feedingType: FeedingType = .bottle,
        amount: Double = 0,
        date: Date = Date(),
        notes: String = "",
        kittens: [Kitten] = []
    ) {
        self.feedingType = feedingType
        self.amount = amount
        self.date = date
        self.notes = notes
        self.kittens = kittens
    }
}
