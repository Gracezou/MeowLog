import SwiftUI
import SwiftData

struct EditFeedingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var log: FeedingLog

    @State private var amountText: String

    init(log: FeedingLog) {
        self.log = log
        _amountText = State(initialValue: String(format: "%.0f", log.amount))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("喂食信息") {
                    Picker("方式", selection: $log.feedingType) {
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
                    DatePicker("时间", selection: $log.date)
                }

                Section("备注") {
                    TextField("备注", text: $log.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("编辑喂食记录")
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
        Double(amountText) != nil && Double(amountText)! > 0
    }

    private func save() {
        if let amount = Double(amountText) {
            log.amount = amount
        }
        dismiss()
    }
}
