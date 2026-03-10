import SwiftUI
import SwiftData

struct KittenListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kitten.sortOrder) private var kittens: [Kitten]
    @State private var showAddSheet = false
    @State private var kittenToDelete: Kitten?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if kittens.isEmpty {
                    emptyState
                } else {
                    kittenList
                }
            }
            .navigationTitle("猫咪档案")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if kittens.count < AppConstants.maxKittens {
                        Button {
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddKittenView()
            }
            .alert("确认删除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    if let kitten = kittenToDelete {
                        // 级联清理 Supabase 照片
                        let photoPaths = kitten.photos.map(\.remoteURL)
                        Task {
                            await SupabaseService.shared.deleteAllPhotos(
                                for: kitten.name,
                                paths: photoPaths
                            )
                        }
                        modelContext.delete(kitten)
                    }
                }
            } message: {
                if let kitten = kittenToDelete {
                    Text("确定要删除「\(kitten.name)」吗？所有相关记录将一并删除。")
                }
            }
            .navigationDestination(for: Kitten.self) { kitten in
                KittenDetailView(kitten: kitten)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("还没有猫咪", systemImage: "cat")
        } description: {
            Text("点击右上角 + 添加你的第一只小猫")
        } actions: {
            Button("添加猫咪") {
                showAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
        }
    }

    // MARK: - List

    private var kittenList: some View {
        List {
            ForEach(kittens) { kitten in
                NavigationLink(value: kitten) {
                    kittenRow(kitten)
                }
            }
            .onDelete(perform: deleteKittens)
            .onMove(perform: moveKittens)
        }
        .listStyle(.insetGrouped)
    }

    private func kittenRow(_ kitten: Kitten) -> some View {
        HStack(spacing: 12) {
            KittenAvatarView(kitten: kitten, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(kitten.name)
                        .font(.headline)
                    Text(kitten.gender.icon)
                        .font(.subheadline)
                }
                HStack(spacing: 8) {
                    Text(kitten.dayAgeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !kitten.colorMarkings.isEmpty {
                        Text(kitten.colorMarkings)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let latest = kitten.latestWeight {
                WeightBadge(weight: latest.weight, dayAge: kitten.dayAge)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func deleteKittens(at offsets: IndexSet) {
        for index in offsets {
            let kitten = kittens[index]
            kittenToDelete = kitten
            showDeleteAlert = true
        }
    }

    private func moveKittens(from source: IndexSet, to destination: Int) {
        var sorted = kittens.sorted { $0.sortOrder < $1.sortOrder }
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, kitten) in sorted.enumerated() {
            kitten.sortOrder = index
        }
    }
}
