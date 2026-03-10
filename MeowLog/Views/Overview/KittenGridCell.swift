import SwiftUI

/// 9 宫格中的单个猫咪卡片
struct KittenGridCell: View {
    let kitten: Kitten

    var body: some View {
        VStack(spacing: 8) {
            KittenAvatarView(kitten: kitten, size: 64)

            Text(kitten.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(kitten.dayAgeText)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let latest = kitten.latestWeight {
                WeightBadge(weight: latest.weight, dayAge: kitten.dayAge)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
