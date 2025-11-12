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
                Text("Day")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("\(day.dayNumber)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
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
                dayNumber: 1,
                name: "Upper Body Power"
            )
        )

        DayCard(
            day: ProgramDay(
                dayNumber: 2,
                name: "Lower Body Strength"
            )
        )
    }
    .padding()
}

#Preview("Rest Day") {
    DayCard(
        day: ProgramDay(
            dayNumber: 7
        )
    )
    .padding()
}
