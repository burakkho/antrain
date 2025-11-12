//
//  ActiveProgramCard.swift
//  antrain
//
//  Created by Claude Code on 2025-11-06.
//

import SwiftUI

/// Card displaying active training program on Home screen
struct ActiveProgramCard: View {
    let program: TrainingProgram
    let currentDayNumber: Int
    let todayWorkout: ProgramDay?
    let onStartWorkout: (() -> Void)?
    let onNextDay: (() -> Void)?  // Callback for advancing to next day

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text("Active Program", comment: "Label for active training program")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColors.textSecondary)

                        Text(program.name)
                            .font(DSTypography.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColors.textPrimary)
                    }

                    Spacer()

                    // Progress badge
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("Day \(currentDayNumber)/\(program.totalDays)", comment: "Program day progress: current/total")
                            .font(DSTypography.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(DSColors.primary)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xxs)
                    .background(DSColors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
                }

                // Progress Bar
                ProgressView(value: Double(currentDayNumber), total: Double(program.totalDays))
                    .tint(DSColors.primary)

                // Today's Workout
                if let todayWorkout = todayWorkout {
                    VStack(spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title3)
                                .foregroundStyle(DSColors.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today's Workout", comment: "Label for today's scheduled workout")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)

                                Text(todayWorkout.displayName)
                                    .font(DSTypography.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(DSColors.textPrimary)
                            }

                            Spacer()
                        }
                        .padding(DSSpacing.sm)
                        .background(DSColors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))

                        // Start Workout Button
                        if let onStartWorkout = onStartWorkout, todayWorkout.template != nil {
                            Button(action: onStartWorkout) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start Today's Workout", comment: "Button to begin today's scheduled workout")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DSSpacing.sm)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    // Rest Day
                    VStack(spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Rest Day", comment: "Label for rest day in program")
                                    .font(DSTypography.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(DSColors.textPrimary)

                                Text("Recovery is important", comment: "Message about importance of rest and recovery")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(DSSpacing.sm)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))

                        // Next Day Button (show if not on last day)
                        // Note: Auto-progression happens in WorkoutSummaryViewModel, this is just for manual override
                        if currentDayNumber < program.totalDays, let onNextDay = onNextDay {
                            Button(action: onNextDay) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Skip to Day \(currentDayNumber + 1)", comment: "Button to advance to next day")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DSSpacing.sm)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.md) {
        // With today's workout
        ActiveProgramCard(
            program: TrainingProgram(
                name: "Push Pull Legs",
                category: .bodybuilding,
                difficulty: .intermediate,
                totalDays: 84  // 12 weeks
            ),
            currentDayNumber: 20,
            todayWorkout: ProgramDay(
                dayNumber: 20,
                name: "Push Day"
            ),
            onStartWorkout: { print("Start workout") },
            onNextDay: { print("Next day") }
        )

        // Rest day
        ActiveProgramCard(
            program: TrainingProgram(
                name: "Starting Strength",
                category: .strengthTraining,
                difficulty: .beginner,
                totalDays: 56  // 8 weeks
            ),
            currentDayNumber: 14,
            todayWorkout: nil,
            onStartWorkout: nil,
            onNextDay: { print("Next day") }
        )
    }
    .padding()
}
