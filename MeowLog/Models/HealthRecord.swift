import Foundation
import SwiftData

// MARK: - Health Type

enum HealthType: String, Codable, CaseIterable, Identifiable {
    case vaccination = "疫苗"
    case deworming = "驱虫"
    case illness = "生病"
    case medication = "用药"
    case veterinaryVisit = "就医"
    case milestone = "里程碑"
    case other = "其他"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .deworming: return "ant.fill"
        case .illness: return "heart.text.clipboard"
        case .medication: return "pills.fill"
        case .veterinaryVisit: return "cross.case.fill"
        case .milestone: return "star.fill"
        case .other: return "note.text"
        }
    }
}

// MARK: - Health Record Model

@Model
final class HealthRecord {
    var healthType: HealthType
    var title: String
    var details: String
    var date: Date

    /// 是否需要提醒
    var reminderEnabled: Bool
    /// 提醒日期
    var reminderDate: Date?

    var kitten: Kitten?

    init(
        healthType: HealthType = .other,
        title: String = "",
        details: String = "",
        date: Date = Date(),
        reminderEnabled: Bool = false,
        reminderDate: Date? = nil,
        kitten: Kitten? = nil
    ) {
        self.healthType = healthType
        self.title = title
        self.details = details
        self.date = date
        self.reminderEnabled = reminderEnabled
        self.reminderDate = reminderDate
        self.kitten = kitten
    }
}
