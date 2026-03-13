import SwiftUI
import SwiftData

struct EditWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var record: WeightRecord

    @State private var weightText: String
    @State private var anomalyWarning: String?

    init(record: WeightRecord) {
        self.record = record
        _weightText = State(initialValue: String(format: "%.0f", record.weight))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("体重") {
                    HStack {
                        TextField("体重", text: $weightText)
                            .keyboardType(.decimalPad)
                        Text("克")
                            .foregroundStyle(.secondary)
                    }
                    DatePicker("称重时间", selection: $record.date)
                }

                if let warning = anomalyWarning {
                    Section {
                        Label(warning, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }

                Section("备注") {
                    TextField("备注", text: $record.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("编辑体重记录")
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
            .onChange(of: weightText) { _, _ in checkAnomaly() }
        }
    }

    private var canSave: Bool {
        Double(weightText) != nil && Double(weightText)! > 0
    }

    private func checkAnomaly() {
        guard let kitten = record.kitten, let weight = Double(weightText) else {
            anomalyWarning = nil
            return
        }
        let vm = WeightViewModel(modelContext: modelContext)
        anomalyWarning = vm.detectAnomaly(kitten: kitten, newWeight: weight)
    }

    private func save() {
        guard let weight = Double(weightText) else { return }
        record.weight = weight
        dismiss()
    }
}
