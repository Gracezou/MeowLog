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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Header
                headerSection

                // MARK: - Milestone
                MilestoneProgressView(dayAge: kitten.dayAge)
                    .padding(.horizontal)

                // MARK: - Sub Tabs
                Picker("", selection: $selectedSubTab) {
                    Text("体重").tag(0)
                    Text("喂食").tag(1)
                    Text("健康").tag(2)
                    Text("相册").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

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
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            KittenAvatarView(kitten: kitten, size: 100)

            HStack(spacing: 8) {
                Text(kitten.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(kitten.gender.icon)
                    .font(.title3)
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
        .padding()
    }

    // MARK: - Weight Tab

    private var weightTab: some View {
        VStack(spacing: 16) {
            WeightChartView(kitten: kitten)

            // 体重记录列表
            let records = kitten.weightRecords.sorted { $0.date > $1.date }
            if !records.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("记录历史")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(records, id: \.date) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(DateHelpers.dateTime(record.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !record.notes.isEmpty {
                                    Text(record.notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            WeightBadge(weight: record.weight, dayAge: record.dayAge)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.bottom)
    }

    // MARK: - Feeding Tab

    private var feedingTab: some View {
        let logs = kitten.feedingLogs.sorted { $0.date > $1.date }
        return VStack(alignment: .leading, spacing: 12) {
            if logs.isEmpty {
                ContentUnavailableView(
                    "暂无喂食记录",
                    systemImage: "drop",
                    description: Text("点击右上角菜单添加喂食记录")
                )
                .frame(height: 200)
            } else {
                ForEach(logs, id: \.date) { log in
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
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom)
    }
}
