import SwiftUI

/// Day information card showing stats, RPE, and modifiers
struct DayInfoCard: View {
    let day: ProgramDay
    let viewModel: DayDetailViewModel

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                // Day of week header
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(DSColors.primary)
                    Text(day.dayOfWeekName)
                        .font(DSTypography.title3)
                        .fontWeight(.semibold)
                }

                Divider()

                // Content based on day type
                if !day.isRestDay {
                    workoutDayContent
                } else {
                    restDayContent
                }
            }
        }
    }

    // MARK: - Workout Day Content

    private var workoutDayContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Workout stats
            HStack(spacing: DSSpacing.xl) {
                StatItemView(
                    icon: "dumbbell.fill",
                    value: "\(viewModel.sortedExercises.count)",
                    label: "Exercises"
                )

                StatItemView(
                    icon: "number",
                    value: "\(viewModel.totalSets)",
                    label: "Sets"
                )

                if let duration = day.template?.estimatedDurationFormatted {
                    StatItemView(
                        icon: "clock",
                        value: duration,
                        label: "Duration"
                    )
                }
            }

            // RPE target
            if let rpeText = viewModel.rpeText,
               let rpeDescription = viewModel.rpeDescription {
                Divider()

                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                        .foregroundStyle(DSColors.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target Intensity")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                        Text(rpeText)
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                        Text(rpeDescription)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }
            }

            // Modifiers
            if viewModel.hasModifiers {
                Divider()

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Adjustments")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)

                    HStack(spacing: DSSpacing.md) {
                        if let intensityText = viewModel.intensityModifierText {
                            ModifierChipView(
                                icon: "bolt.fill",
                                label: "Intensity",
                                value: intensityText,
                                color: day.effectiveIntensityModifier > 1.0 ? .orange : .green
                            )
                        }

                        if let volumeText = viewModel.volumeModifierText {
                            ModifierChipView(
                                icon: "chart.bar.fill",
                                label: "Volume",
                                value: volumeText,
                                color: day.effectiveVolumeModifier > 1.0 ? .orange : .green
                            )
                        }

                        if day.week?.isDeload == true {
                            deloadChip
                        }
                    }
                }
            }
        }
    }

    // MARK: - Rest Day Content

    private var restDayContent: some View {
        HStack(spacing: DSSpacing.md) {
            Image(systemName: "zzz")
                .font(.title)
                .foregroundStyle(DSColors.textSecondary)
            VStack(alignment: .leading, spacing: 4) {
                Text("Rest Day")
                    .font(DSTypography.title3)
                    .foregroundStyle(DSColors.textSecondary)
                Text("Active recovery and restoration")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textTertiary)
            }
        }
    }

    // MARK: - Deload Chip

    private var deloadChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.green)
            Text("Deload")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background {
            RoundedRectangle(cornerRadius: DSSpacing.xs)
                .fill(Color.green.opacity(0.1))
        }
    }
}
