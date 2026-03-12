import SwiftUI
import SwiftData

struct HealthRecordListView: View {
    @Environment(\.modelContext) private var modelContext
    let kitten: Kitten
    @State private var showAddRecord = false
    @State private var recordToDelete: HealthRecord?
    @State private var showDeleteAlert = false

    private var records: [HealthRecord] {
        (kitten.healthRecords ?? []).sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("健康记录")
                    .font(.headline)
                Spacer()
                Button {
                    showAddRecord = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.primary)
                }
            }
            .padding(.horizontal)

            if records.isEmpty {
                ContentUnavailableView(
                    "暂无健康记录",
                    systemImage: "heart.text.clipboard",
                    description: Text("点击 + 添加疫苗、驱虫、就医等记录")
                )
                .frame(height: 200)
            } else {
                ForEach(records, id: \.date) { record in
                    healthRecordRow(record)
                        .contextMenu {
                            Button(role: .destructive) {
                                recordToDelete = record
                                showDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .padding(.bottom)
        .sheet(isPresented: $showAddRecord) {
            AddHealthRecordView(kitten: kitten)
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let record = recordToDelete {
                    modelContext.delete(record)
                }
            }
        } message: {
            Text("确定要删除这条健康记录吗？")
        }
    }

    private func healthRecordRow(_ record: HealthRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: record.healthType.icon)
                .font(.title3)
                .foregroundStyle(AppColors.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(record.healthType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(Capsule())
                    Text(record.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                if !record.details.isEmpty {
                    Text(record.details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(DateHelpers.dateTime(record.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if record.reminderEnabled {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
