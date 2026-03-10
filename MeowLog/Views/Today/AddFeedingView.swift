import SwiftUI
import SwiftData

struct AddFeedingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Kitten.sortOrder) private var allKittens: [Kitten]

    @State private var selectedKittens: Set<Kitten> = []
    @State private var feedingType: FeedingType = .bottle
    @State private var amountText = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var selectAll = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Select Kittens

                Section("选择猫咪") {
                    Toggle("全选", isOn: $selectAll)
                        .onChange(of: selectAll) { _, newValue in
                            if newValue {
                                selectedKittens = Set(allKittens)
                            } else {
                                selectedKittens.removeAll()
                            }
                        }
                    ForEach(allKittens) { kitten in
                        let isSelected = selectedKittens.contains(kitten)
                        Button {
                            if isSelected {
                                selectedKittens.remove(kitten)
                            } else {
                                selectedKittens.insert(kitten)
                            }
                        } label: {
                            HStack {
                                KittenAvatarView(kitten: kitten, size: 32)
                                Text(kitten.name)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColors.primary)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                // MARK: - Feeding Info

                Section("喂食信息") {
                    Picker("方式", selection: $feedingType) {
                        ForEach(FeedingType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    HStack {
                        TextField("用量", text: $amountText)
                            .keyboardType(.decimalPad)
                        Text("ml")
                            .foregroundStyle(.secondary)
                    }
                    DatePicker("时间", selection: $date)
                }

                Section("备注") {
                    TextField("备注", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("记录喂食")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !selectedKittens.isEmpty && Double(amountText) != nil && Double(amountText)! > 0
    }

    private func save() {
        guard let amount = Double(amountText) else { return }
        let vm = FeedingViewModel(modelContext: modelContext)
        vm.addFeeding(kittens: Array(selectedKittens), type: feedingType, amount: amount, date: date, notes: notes)
        dismiss()
    }
}
