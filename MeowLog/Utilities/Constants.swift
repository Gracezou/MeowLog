import SwiftUI

// MARK: - App Colors

enum AppColors {
    static let primary = Color(hex: "FF6B6B")
    static let secondary = Color(hex: "4ECDC4")
    static let accent = Color(hex: "FFE66D")
    static let background = Color(hex: "F7F7F7")
    static let cardBackground = Color(.systemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)

    // 猫咪默认颜色（用于头像占位）
    static let kittenColors: [Color] = [
        Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "FFE66D"),
        Color(hex: "A8E6CF"), Color(hex: "FF8B94"), Color(hex: "B5EAD7"),
        Color(hex: "C7CEEA"), Color(hex: "FFDAC1"), Color(hex: "E2F0CB"),
    ]
}

// MARK: - Milestones

/// 幼猫成长里程碑定义（按日龄）
enum Milestone: Int, CaseIterable, Identifiable {
    case birth = 0
    case eyesOpen = 10       // 睁眼
    case earsOpen = 14       // 耳道打开
    case firstSteps = 21     // 开始走路
    case startWeaning = 28   // 开始断奶
    case fullyWeaned = 56    // 完全断奶
    case readyAdoption = 84  // 可以领养

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .birth: return "出生"
        case .eyesOpen: return "睁眼"
        case .earsOpen: return "耳道打开"
        case .firstSteps: return "开始走路"
        case .startWeaning: return "开始断奶"
        case .fullyWeaned: return "完全断奶"
        case .readyAdoption: return "可以领养"
        }
    }

    var dayAge: Int { rawValue }

    var icon: String {
        switch self {
        case .birth: return "sparkle"
        case .eyesOpen: return "eye"
        case .earsOpen: return "ear"
        case .firstSteps: return "figure.walk"
        case .startWeaning: return "cup.and.saucer"
        case .fullyWeaned: return "fork.knife"
        case .readyAdoption: return "house.fill"
        }
    }
}

// MARK: - Weight Health Range

/// 幼猫体重健康区间（单位：克）
enum WeightRange {
    /// 根据日龄返回 (最低, 正常低, 正常高, 最高) 体重范围
    static func range(forDayAge dayAge: Int) -> (min: Double, normalLow: Double, normalHigh: Double, max: Double) {
        switch dayAge {
        case 0...7:
            return (70, 90, 130, 170)
        case 8...14:
            return (110, 150, 220, 280)
        case 15...21:
            return (170, 210, 310, 400)
        case 22...28:
            return (230, 270, 400, 520)
        case 29...35:
            return (290, 340, 500, 640)
        case 36...42:
            return (350, 400, 590, 760)
        case 43...49:
            return (410, 470, 680, 880)
        case 50...56:
            return (470, 540, 770, 1000)
        default:
            // 8 周以上，线性估算
            let weeks = Double(dayAge) / 7.0
            let baseLow = 540 + (weeks - 8) * 70
            let baseHigh = 770 + (weeks - 8) * 100
            return (baseLow * 0.85, baseLow, baseHigh, baseHigh * 1.3)
        }
    }

    /// 判断体重是否在健康区间
    static func status(weight: Double, dayAge: Int) -> WeightStatus {
        let r = range(forDayAge: dayAge)
        if weight < r.min { return .underweight }
        if weight < r.normalLow { return .belowNormal }
        if weight <= r.normalHigh { return .normal }
        if weight <= r.max { return .aboveNormal }
        return .overweight
    }
}

enum WeightStatus: String {
    case underweight = "偏轻"
    case belowNormal = "略轻"
    case normal = "正常"
    case aboveNormal = "略重"
    case overweight = "偏重"

    var color: Color {
        switch self {
        case .underweight: return .red
        case .belowNormal: return .orange
        case .normal: return .green
        case .aboveNormal: return .orange
        case .overweight: return .red
        }
    }
}

// MARK: - App Constants

enum AppConstants {
    static let maxKittens = 9
    static let avatarMaxSizeKB = 200
    static let photoMaxSizeMB = 5
    static let gridColumns = 3
}
