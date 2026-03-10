import SwiftUI
import SwiftData
import PhotosUI

struct AddKittenView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Kitten.sortOrder) private var existingKittens: [Kitten]

    @State private var name = ""
    @State private var gender: Gender = .unknown
    @State private var birthDate = Date()
    @State private var colorMarkings = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarData: Data?

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Avatar

                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            if let data = avatarData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.kittenColors[existingKittens.count % AppColors.kittenColors.count])
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                // MARK: - Basic Info

                Section("基本信息") {
                    TextField("猫咪名字", text: $name)
                    Picker("性别", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Text("\(g.icon) \(g.rawValue)").tag(g)
                        }
                    }
                    DatePicker("出生日期", selection: $birthDate, displayedComponents: .date)
                    TextField("毛色特征", text: $colorMarkings)
                }

                // MARK: - Notes

                Section("备注") {
                    TextField("备注信息", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("添加猫咪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        // 压缩头像到 200KB 以内
                        let resized = image.resized(maxDimension: 400)
                        avatarData = resized.compressed(maxKB: AppConstants.avatarMaxSizeKB)
                    }
                }
            }
        }
    }

    private func save() {
        let kitten = Kitten(
            name: name.trimmingCharacters(in: .whitespaces),
            gender: gender,
            birthDate: birthDate,
            colorMarkings: colorMarkings,
            notes: notes,
            avatarData: avatarData,
            sortOrder: existingKittens.count
        )
        modelContext.insert(kitten)
        dismiss()
    }
}
