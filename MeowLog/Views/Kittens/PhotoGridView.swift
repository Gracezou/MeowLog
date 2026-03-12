import SwiftUI
import SwiftData
import PhotosUI

/// 猫咪相册网格：上传/查看/删除照片
struct PhotoGridView: View {
    @Environment(\.modelContext) private var modelContext
    let kitten: Kitten

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploading = false
    @State private var photoToDelete: KittenPhoto?
    @State private var showDeleteAlert = false
    @State private var selectedImage: KittenPhoto?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    private var photos: [KittenPhoto] {
        (kitten.photos ?? []).sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("相册 (\(photos.count))")
                    .font(.headline)
                Spacer()
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("添加", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.primary)
                }
            }
            .padding(.horizontal)

            if isUploading {
                ProgressView("上传中...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            if photos.isEmpty {
                ContentUnavailableView(
                    "暂无照片",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("点击 + 上传猫咪的成长照片")
                )
                .frame(height: 200)
            } else {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(photos, id: \.remoteURL) { photo in
                        photoCell(photo)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task { await handlePhotoSelection(newValue) }
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let photo = photoToDelete {
                    Task { await deletePhoto(photo) }
                }
            }
        } message: {
            Text("确定要删除这张照片吗？")
        }
        .sheet(item: $selectedImage) { photo in
            photoDetail(photo)
        }
    }

    // MARK: - Photo Cell

    private func photoCell(_ photo: KittenPhoto) -> some View {
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
        .frame(height: 120)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onTapGesture {
            selectedImage = photo
        }
        .contextMenu {
            Button(role: .destructive) {
                photoToDelete = photo
                showDeleteAlert = true
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }

    // MARK: - Photo Detail

    private func photoDetail(_ photo: KittenPhoto) -> some View {
        NavigationStack {
            VStack {
                AsyncImage(url: SupabaseService.shared.publicURL(for: photo.remoteURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Color.gray
                    }
                }

                VStack(spacing: 4) {
                    Text("第 \(photo.dayAge) 天")
                        .font(.headline)
                    Text(DateHelpers.dateTime(photo.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !photo.caption.isEmpty {
                        Text(photo.caption)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationTitle("照片详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { selectedImage = nil }
                }
            }
        }
    }

    // MARK: - Actions

    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        isUploading = true
        defer { isUploading = false }

        // 压缩照片
        let resized = image.resized(maxDimension: 1920)
        guard let compressed = resized.compressed(maxKB: AppConstants.photoMaxSizeMB * 1024) else { return }

        let fileName = "\(Int(Date().timeIntervalSince1970)).jpg"

        do {
            let remotePath = try await SupabaseService.shared.uploadPhoto(
                imageData: compressed,
                kittenName: kitten.name,
                fileName: fileName
            )
            let photo = KittenPhoto(
                remoteURL: remotePath,
                localFileName: fileName,
                date: Date(),
                kitten: kitten
            )
            modelContext.insert(photo)
        } catch {
            // 上传失败静默处理
            print("照片上传失败: \(error)")
        }
    }

    private func deletePhoto(_ photo: KittenPhoto) async {
        try? await SupabaseService.shared.deletePhoto(path: photo.remoteURL)
        modelContext.delete(photo)
    }
}

// KittenPhoto 已通过 PersistentModel 协议自动遵循 Identifiable
