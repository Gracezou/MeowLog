import Foundation

enum DateHelpers {
    /// 计算日龄（从出生日期到今天）
    static func dayAge(from birthDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }

    /// 计算日龄（从出生日期到指定日期）
    static func dayAge(from birthDate: Date, to date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: date).day ?? 0
    }

    /// 格式化日龄显示
    static func dayAgeText(_ dayAge: Int) -> String {
        if dayAge < 0 { return "未出生" }
        if dayAge == 0 { return "出生当天" }
        let weeks = dayAge / 7
        let days = dayAge % 7
        if weeks == 0 { return "\(days)天" }
        if days == 0 { return "\(weeks)周" }
        return "\(weeks)周\(days)天"
    }

    /// 当前里程碑
    static func currentMilestone(dayAge: Int) -> Milestone {
        let sorted = Milestone.allCases.sorted { $0.dayAge < $1.dayAge }
        var current = Milestone.birth
        for m in sorted where dayAge >= m.dayAge {
            current = m
        }
        return current
    }

    /// 下一个里程碑
    static func nextMilestone(dayAge: Int) -> Milestone? {
        Milestone.allCases
            .sorted { $0.dayAge < $1.dayAge }
            .first { $0.dayAge > dayAge }
    }

    /// 里程碑进度 (0...1)
    static func milestoneProgress(dayAge: Int) -> Double {
        let maxDay = Milestone.readyAdoption.dayAge
        return min(1.0, Double(dayAge) / Double(maxDay))
    }

    /// 今天的开始时间
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }

    /// 格式化日期为短格式
    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    /// 格式化日期时间
    static func dateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }

    /// 格式化时间
    static func timeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
