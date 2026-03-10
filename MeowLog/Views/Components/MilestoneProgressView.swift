import SwiftUI

/// 里程碑进度条组件
struct MilestoneProgressView: View {
    let dayAge: Int

    private var progress: Double {
        DateHelpers.milestoneProgress(dayAge: dayAge)
    }

    private var currentMilestone: Milestone {
        DateHelpers.currentMilestone(dayAge: dayAge)
    }

    private var nextMilestone: Milestone? {
        DateHelpers.nextMilestone(dayAge: dayAge)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: currentMilestone.icon)
                    .foregroundStyle(AppColors.primary)
                Text(currentMilestone.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if let next = nextMilestone {
                    Text("下一个: \(next.title) (第\(next.dayAge)天)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)

                    ForEach(Milestone.allCases) { milestone in
                        let x = geometry.size.width * Double(milestone.dayAge) / Double(Milestone.readyAdoption.dayAge)
                        Circle()
                            .fill(dayAge >= milestone.dayAge ? AppColors.primary : Color(.systemGray4))
                            .frame(width: 10, height: 10)
                            .position(x: x, y: 4)
                    }
                }
            }
            .frame(height: 12)
        }
    }
}
