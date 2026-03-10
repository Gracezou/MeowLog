import SwiftUI

struct KittenDetailView: View {
    @Bindable var kitten: Kitten
    @State private var showEditSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Header
                headerSection

                // MARK: - Milestone
                MilestoneProgressView(dayAge: kitten.dayAge)
                    .padding(.horizontal)

                // MARK: - Placeholder
                Text("详情页子 Tab（待实现）")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationTitle(kitten.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditKittenView(kitten: kitten)
        }
    }

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
}
