import Foundation
import UIKit

/// Supabase Storage REST API 服务
/// 使用前需配置 supabaseURL 和 supabaseKey
actor SupabaseService {
    static let shared = SupabaseService()

    // TODO: 替换为实际的 Supabase 项目配置
    private let supabaseURL = "https://YOUR_PROJECT.supabase.co"
    private let supabaseKey = "YOUR_ANON_KEY"
    private let bucketName = "kitten-photos"

    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "apikey": supabaseKey,
            "Authorization": "Bearer \(supabaseKey)",
        ]
        return URLSession(configuration: config)
    }

    // MARK: - Upload

    /// 上传照片到 Supabase Storage
    /// - Returns: 远程文件路径
    func uploadPhoto(imageData: Data, kittenName: String, fileName: String) async throws -> String {
        let path = "\(kittenName)/\(fileName)"
        let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(path)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SupabaseError.uploadFailed
        }

        return path
    }

    // MARK: - Download

    /// 获取照片的公开 URL
    func publicURL(for path: String) -> URL? {
        URL(string: "\(supabaseURL)/storage/v1/object/public/\(bucketName)/\(path)")
    }

    /// 下载照片数据
    func downloadPhoto(path: String) async throws -> Data {
        guard let url = publicURL(for: path) else {
            throw SupabaseError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SupabaseError.downloadFailed
        }
        return data
    }

    // MARK: - Delete

    /// 删除照片
    func deletePhoto(path: String) async throws {
        let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(path)")!

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SupabaseError.deleteFailed
        }
    }

    /// 批量删除照片（用于删除猫咪时清理）
    func deleteAllPhotos(for kittenName: String, paths: [String]) async {
        for path in paths {
            try? await deletePhoto(path: path)
        }
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .uploadFailed: return "照片上传失败"
        case .downloadFailed: return "照片下载失败"
        case .deleteFailed: return "照片删除失败"
        case .invalidURL: return "无效的 URL"
        }
    }
}
