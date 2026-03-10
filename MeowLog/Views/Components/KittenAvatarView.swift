import SwiftUI

/// 猫咪头像组件：显示图片或颜色占位符
struct KittenAvatarView: View {
    let kitten: Kitten
    var size: CGFloat = 60

    var body: some View {
        Group {
            if let data = kitten.avatarData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // 颜色占位符 + 首字母
                ZStack {
                    AppColors.kittenColors[kitten.colorIndex]
                    Text(String(kitten.name.prefix(1)))
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
