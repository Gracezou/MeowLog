import SwiftUI
import SwiftData

/// 按日龄分组的照片画廊（所有猫咪）
struct PhotoGalleryView: View {
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]

    private var photosByWeek: [(week: Int, photos: [(kitten: Kitten, photo: KittenPhoto)])] {
        var grouped: [Int: [(kitten: Kitten, photo: KittenPhoto)]] = [:]

        for kitten in kittens {
            for photo in kitten.photos {
                let week = photo.dayAge / 7
                grouped[week, default: []].append((kitten: kitten, photo: photo))
            }
        }

        return grouped.keys.sorted().map { week in
            (week: week, photos: grouped[week]!.sorted { $0.photo.date > $1.photo.date })
        }
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    var body: some View {
        if photosByWeek.isEmpty {
            ContentUnavailableView(
                "暂无照片",
                systemImage: "photo.on.rectangle.angled",
                description: Text("在猫咪详情页中上传照片")
            )
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(photosByWeek, id: \.week) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("第 \(group.week) 周")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: columns, spacing: 4) {
                                ForEach(group.photos, id: \.photo.remoteURL) { item in
                                    galleryCell(kitten: item.kitten, photo: item.photo)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }

    private func galleryCell(kitten: Kitten, photo: KittenPhoto) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: SupabaseService.shared.publicURL(for: photo.remoteURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    Color.gray
                }
            }
            .frame(height: 90)
            .clipped()

            // 猫咪名字标签
            Text(kitten.name)
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
