import SwiftUI

/// 猫咪相册网格（待 Phase 5 完整实现）
struct PhotoGridView: View {
    let kitten: Kitten

    var body: some View {
        ContentUnavailableView(
            "相册功能",
            systemImage: "photo.on.rectangle.angled",
            description: Text("相册功能即将上线")
        )
        .frame(height: 200)
    }
}
