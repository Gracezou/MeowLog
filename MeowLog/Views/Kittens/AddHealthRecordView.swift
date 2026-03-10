import SwiftUI

struct AddHealthRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let kitten: Kitten

    @State private var healthType: HealthType = .other
    @State private var title = ""
    @State private var details = ""
    @State private var date = Date()
    @State private var reminderEnabled = false
    @State private var reminderDate = Date().addingTimeInterval(86400)

    var body: some View {
        NavigationStack {
            Form {
                Section("类型") {
                    Picker("类型", selection: $healthType) {
                        ForEach(HealthType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                }

                Section("记录信息") {
                    TextField("标题", text: $title)
                    TextField("详细描述", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                    DatePicker("日期", selection: $date)
                }

                Section("提醒") {
                    Toggle("设置提醒", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("提醒时间", selection: $reminderDate)
                    }
                }
            }
            .navigationTitle("添加健康记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let vm = KittenViewModel(modelContext: modelContext)
        vm.addHealthRecord(
            to: kitten,
            type: healthType,
            title: title.trimmingCharacters(in: .whitespaces),
            details: details,
            date: date,
            reminderEnabled: reminderEnabled,
            reminderDate: reminderEnabled ? reminderDate : nil
        )

        // 设置本地通知
        if reminderEnabled {
            let id = "\(kitten.name)_health_\(date.timeIntervalSince1970)"
            NotificationManager.scheduleReminder(
                id: id,
                title: "健康提醒 - \(kitten.name)",
                body: title,
                date: reminderDate
            )
        }

        dismiss()
    }
}
