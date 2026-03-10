import SwiftUI

/// 体重标签组件：显示体重值和健康状态颜色
struct WeightBadge: View {
    let weight: Double
    let dayAge: Int

    var body: some View {
        let status = WeightRange.status(weight: weight, dayAge: dayAge)
        HStack(spacing: 4) {
            Image(systemName: "scalemass.fill")
                .font(.caption2)
            Text(weight.weightText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.15))
        .foregroundStyle(status.color)
        .clipShape(Capsule())
    }
}
