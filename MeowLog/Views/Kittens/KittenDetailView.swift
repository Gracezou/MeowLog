import SwiftUI
import SwiftData

struct KittenDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var kitten: Kitten
    @State private var showEditSheet = false
    @State private var selectedSubTab = 0
    @State private var showAddWeight = false
    @State private var showAddFeeding = false
    @State private var showAddHealth = false
    @State private var weightRecordToEdit: WeightRecord?
    @State private var feedingLogToEdit: FeedingLog?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                headerSection

                // MARK: - Sub Tabs
                Picker("", selection: $selectedSubTab) {
                    Text("体重").tag(0)
                    Text("喂食").tag(1)
                    Text("健康").tag(2)
                    Text("相册").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                // MARK: - Tab Content
                switch selectedSubTab {
                case 0:
                    weightTab
                case 1:
                    feedingTab
                case 2:
                    HealthRecordListView(kitten: kitten)
                case 3:
                    PhotoGridView(kitten: kitten)
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle(kitten.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("编辑信息") { showEditSheet = true }
                    Button { showAddWeight = true } label: {
                        Label("记录体重", systemImage: "scalemass.fill")
                    }
                    Button { showAddFeeding = true } label: {
                        Label("记录喂食", systemImage: "drop.fill")
                    }
                    Button { showAddHealth = true } label: {
                        Label("添加健康记录", systemImage: "heart.text.clipboard")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditKittenView(kitten: kitten)
        }
        .sheet(isPresented: $showAddWeight) {
            AddWeightView(preselectedKitten: kitten)
        }
        .sheet(isPresented: $showAddFeeding) {
            AddFeedingView()
        }
        .sheet(isPresented: $showAddHealth) {
            AddHealthRecordView(kitten: kitten)
        }
        .sheet(item: $weightRecordToEdit) { record in
            EditWeightView(record: record)
        }
        .sheet(item: $feedingLogToEdit) { log in
            EditFeedingView(log: log)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // 渐变背景
            LinearGradient(
                colors: [AppColors.kittenColors[kitten.colorIndex].opacity(0.6), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)

            VStack(spacing: 12) {
                KittenAvatarView(kitten: kitten, size: 140)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                HStack(spacing: 8) {
                    Text(kitten.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(kitten.gender.icon)
                        .font(.title2)
                }

                HStack(spacing: 16) {
                    Label(kitten.dayAgeText, systemImage: "calendar")
                    if !kitten.colorMarkings.isEmpty {
                        Label(kitten.colorMarkings, systemImage: "paintpalette")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let latest = kitten.latestWeight {
                    WeightBadge(weight: latest.weight, dayAge: kitten.dayAge)
                }
            }
            .padding(.bottom, 16)
        }
        // 里程碑进度条
        .overlay(alignment: .bottom) {
            EmptyView()
        }
    }

    // MARK: - Weight Tab

    private var weightTab: some View {
        VStack(spacing: 16) {
            WeightChartView(kitten: kitten)

            let records = (kitten.weightRecords ?? []).sorted { $0.date > $1.date }
            if !records.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("记录历史")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    ForEach(records) { record in
                        weightRow(record)
                            .contentShape(Rectangle())
                            .onTapGesture { weightRecordToEdit = record }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(record)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                                Button {
                                    weightRecordToEdit = record
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        Divider().padding(.horizontal)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }

    private func weightRow(_ record: WeightRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(DateHelpers.dateTime(record.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !record.notes.isEmpty {
                    Text(record.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            WeightBadge(weight: record.weight, dayAge: record.dayAge)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    // MARK: - Feeding Tab

    private var feedingTab: some View {
        let logs = (kitten.feedingLogs ?? []).sorted { $0.date > $1.date }
        return VStack(alignment: .leading, spacing: 0) {
            if logs.isEmpty {
                ContentUnavailableView(
                    "暂无喂食记录",
                    systemImage: "drop",
                    description: Text("点击右上角菜单添加喂食记录")
                )
                .frame(height: 200)
            } else {
                Text("喂食历史")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                ForEach(logs) { log in
                    feedingRow(log)
                        .contentShape(Rectangle())
                        .onTapGesture { feedingLogToEdit = log }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(log)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            Button {
                                feedingLogToEdit = log
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    Divider().padding(.horizontal)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func feedingRow(_ log: FeedingLog) -> some View {
        HStack(spacing: 12) {
            Image(systemName: log.feedingType.icon)
                .font(.title3)
                .foregroundStyle(AppColors.secondary)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(log.feedingType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(DateHelpers.dateTime(log.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "%.0f ml", log.amount))
                .font(.subheadline)
                .fontWeight(.medium)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
