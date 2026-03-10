import SwiftUI
import SwiftData

struct AddWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]

    @State private var selectedKitten: Kitten?
    @State private var weightText = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var anomalyWarning: String?

    /// 可选：预选猫咪
    var preselectedKitten: Kitten?

    var body: some View {
        NavigationStack {
            Form {
                Section("选择猫咪") {
                    if let preset = preselectedKitten {
                        HStack {
                            KittenAvatarView(kitten: preset, size: 40)
                            Text(preset.name)
                                .font(.headline)
                        }
                    } else {
                        Picker("猫咪", selection: $selectedKitten) {
                            Text("请选择").tag(nil as Kitten?)
                            ForEach(kittens) { kitten in
                                HStack {
                                    Text(kitten.name)
                                    Text(kitten.gender.icon)
                                }
                                .tag(kitten as Kitten?)
                            }
                        }
                    }
                }

                Section("体重") {
                    HStack {
                        TextField("体重", text: $weightText)
                            .keyboardType(.decimalPad)
                        Text("克")
                            .foregroundStyle(.secondary)
                    }
                    DatePicker("称重时间", selection: $date)
                }

                if let warning = anomalyWarning {
                    Section {
                        Label(warning, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }

                Section("备注") {
                    TextField("备注", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("记录体重")
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
            .onChange(of: weightText) { _, _ in
                checkAnomaly()
            }
        }
    }

    private var targetKitten: Kitten? {
        preselectedKitten ?? selectedKitten
    }

    private var canSave: Bool {
        targetKitten != nil && Double(weightText) != nil && Double(weightText)! > 0
    }

    private func checkAnomaly() {
        guard let kitten = targetKitten,
              let weight = Double(weightText) else {
            anomalyWarning = nil
            return
        }
        let vm = WeightViewModel(modelContext: modelContext)
        anomalyWarning = vm.detectAnomaly(kitten: kitten, newWeight: weight)
    }

    private func save() {
        guard let kitten = targetKitten,
              let weight = Double(weightText) else { return }
        let vm = WeightViewModel(modelContext: modelContext)
        vm.addWeight(to: kitten, weight: weight, date: date, notes: notes)
        dismiss()
    }
}
