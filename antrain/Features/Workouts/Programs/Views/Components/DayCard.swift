//
//  DayCard.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Card view for displaying a program day
struct DayCard: View {
    let day: ProgramDay

    var body: some View {
        HStack(spacing: 12) {
            // Day indicator
            VStack(spacing: 2) {
                Text(day.shortDayOfWeekName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50)

            if day.isRestDay {
                // Rest day
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rest Day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("No workout scheduled")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "zzz")
                    .foregroundStyle(.secondary)
                    .font(.title3)

            } else {
                // Training day
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if let template = day.template {
                        HStack(spacing: 4) {
                            Image(systemName: "dumbbell.fill")
                                .font(.caption2)
                            Text("\(template.exerciseCount) exercises")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    // Modifiers
                    if day.intensityOverride != nil || day.volumeOverride != nil {
                        HStack(spacing: 8) {
                            if let intensity = day.intensityOverride {
                                Label {
                                    Text(String(format: "%.0f%%", intensity * 100))
                                        .font(.caption2)
                                } icon: {
                                    Image(systemName: "bolt.fill")
                                }
                            }
                            if let volume = day.volumeOverride {
                                Label {
                                    Text(String(format: "%.0f%%", volume * 100))
                                        .font(.caption2)
                                } icon: {
                                    Image(systemName: "chart.bar.fill")
                                }
                            }
                        }
                        .foregroundStyle(.orange)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
}

#Preview("Training Day") {
    VStack(spacing: 8) {
        DayCard(
            day: ProgramDay(
                dayOfWeek: 2, // Monday
                name: "Upper Body Power"
            )
        )

        DayCard(
            day: ProgramDay(
                dayOfWeek: 3, // Tuesday
                name: "Lower Body Strength",
                intensityOverride: 1.1
            )
        )
    }
    .padding()
}

#Preview("Rest Day") {
    DayCard(
        day: ProgramDay(
            dayOfWeek: 1 // Sunday
        )
    )
    .padding()
}
