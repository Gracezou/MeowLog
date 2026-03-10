import Foundation
import SwiftData

@Model
final class KittenPhoto {
    /// Supabase Storage 中的远程 URL
    var remoteURL: String
    /// 本地缓存文件名
    var localFileName: String
    /// 拍摄/上传日期
    var date: Date
    /// 照片描述
    var caption: String

    var kitten: Kitten?

    init(
        remoteURL: String = "",
        localFileName: String = "",
        date: Date = Date(),
        caption: String = "",
        kitten: Kitten? = nil
    ) {
        self.remoteURL = remoteURL
        self.localFileName = localFileName
        self.date = date
        self.caption = caption
        self.kitten = kitten
    }

    /// 该照片对应的日龄
    var dayAge: Int {
        guard let kitten else { return 0 }
        return DateHelpers.dayAge(from: kitten.birthDate, to: date)
    }
}
