import Foundation
import SwiftData

// MARK: - Gender

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "公"
    case female = "母"
    case unknown = "未知"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .male: return "♂"
        case .female: return "♀"
        case .unknown: return "?"
        }
    }
}

// MARK: - Kitten Model

@Model
final class Kitten {
    var name: String
    var gender: Gender
    var birthDate: Date
    var colorMarkings: String  // 毛色特征
    var notes: String

    /// 头像图片数据（< 200KB，压缩后的 JPEG）
    @Attribute(.externalStorage)
    var avatarData: Data?

    /// 显示排序
    var sortOrder: Int

    /// 创建时间
    var createdAt: Date

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \WeightRecord.kitten)
    var weightRecords: [WeightRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \HealthRecord.kitten)
    var healthRecords: [HealthRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \KittenPhoto.kitten)
    var photos: [KittenPhoto] = []

    @Relationship(inverse: \FeedingLog.kittens)
    var feedingLogs: [FeedingLog] = []

    init(
        name: String,
        gender: Gender = .unknown,
        birthDate: Date = Date(),
        colorMarkings: String = "",
        notes: String = "",
        avatarData: Data? = nil,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.colorMarkings = colorMarkings
        self.notes = notes
        self.avatarData = avatarData
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }

    // MARK: - Computed

    var dayAge: Int {
        DateHelpers.dayAge(from: birthDate)
    }

    var dayAgeText: String {
        DateHelpers.dayAgeText(dayAge)
    }

    /// 最新体重记录
    var latestWeight: WeightRecord? {
        weightRecords.sorted { $0.date > $1.date }.first
    }

    /// 颜色索引（基于排序顺序）
    var colorIndex: Int {
        sortOrder % AppColors.kittenColors.count
    }
}
