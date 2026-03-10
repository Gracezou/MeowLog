import SwiftUI
import UIKit

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIImage Compression

extension UIImage {
    /// 压缩图片到指定最大文件大小（KB）
    func compressed(maxKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        let maxBytes = maxKB * 1024
        guard var data = jpegData(compressionQuality: compression) else { return nil }
        while data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            guard let newData = jpegData(compressionQuality: compression) else { return data }
            data = newData
        }
        return data
    }

    /// 等比缩放到指定最大尺寸
    func resized(maxDimension: CGFloat) -> UIImage {
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        if ratio >= 1.0 { return self }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Date Helpers

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

// MARK: - Double Formatting

extension Double {
    /// 格式化体重显示（克）
    var weightText: String {
        if self >= 1000 {
            return String(format: "%.2f kg", self / 1000)
        }
        return String(format: "%.0f g", self)
    }
}
