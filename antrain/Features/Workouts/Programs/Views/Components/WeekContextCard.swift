import SwiftUI

/// Week context card showing week details and phase
struct WeekContextCard: View {
    let week: ProgramWeek

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Week Context")
                .font(DSTypography.headline)

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    // Week header with phase
                    HStack {
                        Text("Week \(week.weekNumber)")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)

                        if let phase = week.phaseTag {
                            Spacer()
                            PhaseIndicator(phase: phase, style: .compact)
                        }
                    }

                    // Week name
                    if let weekName = week.name, !weekName.isEmpty {
                        Text(weekName)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }

                    // Week notes
                    if let weekNotes = week.notes, !weekNotes.isEmpty {
                        Divider()
                        Text(weekNotes)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }
            }
        }
    }
}
