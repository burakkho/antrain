import SwiftUI

/// Quick actions card for starting workouts
struct QuickActionsCard: View {
    let onStartLifting: () -> Void
    let onLogCardio: () -> Void
    let onLogMetCon: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Quick Actions")
                .font(DSTypography.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, DSSpacing.md)

            HStack(spacing: DSSpacing.sm) {
                QuickActionButton(
                    icon: "dumbbell.fill",
                    title: "Start Lifting",
                    action: onStartLifting
                )

                QuickActionButton(
                    icon: "figure.run",
                    title: "Log Cardio",
                    action: onLogCardio
                )

                QuickActionButton(
                    icon: "flame.fill",
                    title: "Log MetCon",
                    action: onLogMetCon
                )
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
}
