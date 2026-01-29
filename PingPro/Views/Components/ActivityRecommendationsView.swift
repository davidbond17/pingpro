import SwiftUI

struct ActivityRecommendationsView: View {
    let avgLatency: Double?
    let packetLoss: Double

    @State private var isExpanded = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    withAnimation(.spring(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundStyle(NetworkTheme.accent)

                        Text("What You Can Do")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(NetworkTheme.textPrimary)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(NetworkTheme.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                if isExpanded {
                    if avgLatency != nil {
                        activitiesContent
                    } else {
                        Text("Start monitoring to see activity recommendations")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(NetworkTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var activitiesContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            let recommendations = ActivityRecommender.getRecommendations(
                avgLatency: avgLatency,
                packetLoss: packetLoss
            )

            let goodActivities = recommendations.filter { $0.status == .excellent || $0.status == .good }
            let poorActivities = recommendations.filter { $0.status == .poor }

            if !goodActivities.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader(
                        title: "Works Great",
                        icon: "checkmark.circle.fill",
                        color: NetworkTheme.accentGreen
                    )

                    ForEach(goodActivities, id: \.activity.name) { recommendation in
                        activityRow(
                            activity: recommendation.activity,
                            status: recommendation.status,
                            message: recommendation.message
                        )
                    }
                }
            }

            if !poorActivities.isEmpty {
                Divider()
                    .background(NetworkTheme.textTertiary.opacity(0.2))

                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader(
                        title: "May Struggle",
                        icon: "exclamationmark.triangle.fill",
                        color: NetworkTheme.accentOrange
                    )

                    ForEach(poorActivities, id: \.activity.name) { recommendation in
                        activityRow(
                            activity: recommendation.activity,
                            status: recommendation.status,
                            message: recommendation.message
                        )
                    }
                }
            }
        }
    }

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(NetworkTheme.textPrimary)
        }
    }

    private func activityRow(
        activity: NetworkActivity,
        status: ActivityStatus,
        message: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.system(size: 20))
                .foregroundStyle(statusColor(status))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(NetworkTheme.textPrimary)

                Text(activity.description)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(NetworkTheme.textTertiary)
            }

            Spacer()

            statusBadge(status: status, message: message)
        }
        .padding(.vertical, 6)
    }

    private func statusBadge(status: ActivityStatus, message: String) -> some View {
        Text(message)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.8))
            .clipShape(Capsule())
    }

    private func statusColor(_ status: ActivityStatus) -> Color {
        switch status {
        case .excellent:
            return NetworkTheme.accentGreen
        case .good:
            return NetworkTheme.accent
        case .poor:
            return NetworkTheme.accentOrange
        }
    }
}
