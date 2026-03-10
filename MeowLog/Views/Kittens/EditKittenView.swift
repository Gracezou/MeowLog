import SwiftUI
import PhotosUI

struct EditKittenView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var kitten: Kitten

    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Avatar

                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            KittenAvatarView(kitten: kitten, size: 100)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                // MARK: - Basic Info

                Section("基本信息") {
                    TextField("猫咪名字", text: $kitten.name)
                    Picker("性别", selection: $kitten.gender) {
                        ForEach(Gender.allCases) { g in
                            Text("\(g.icon) \(g.rawValue)").tag(g)
                        }
                    }
                    DatePicker("出生日期", selection: $kitten.birthDate, displayedComponents: .date)
                    TextField("毛色特征", text: $kitten.colorMarkings)
                }

                // MARK: - Notes

                Section("备注") {
                    TextField("备注信息", text: $kitten.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("编辑猫咪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        let resized = image.resized(maxDimension: 400)
                        kitten.avatarData = resized.compressed(maxKB: AppConstants.avatarMaxSizeKB)
                    }
                }
            }
        }
    }
}
