//
//  WeekCard.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Card view for displaying a program week
struct WeekCard: View {
    let week: ProgramWeek
    var isCurrentWeek: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Week indicator
            VStack(spacing: 4) {
                Text("Week")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(week.weekNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCurrentWeek ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
            }

            VStack(alignment: .leading, spacing: 6) {
                // Week name
                HStack {
                    Text(week.displayName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    if isCurrentWeek {
                        Text("Current")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background {
                                Capsule()
                                    .fill(Color.accentColor)
                            }
                            .foregroundStyle(.white)
                    }
                }

                // Phase tag
                if let phase = week.phaseTag {
                    HStack(spacing: 4) {
                        Image(systemName: phase.iconName)
                            .font(.caption2)
                        Text(phase.displayName)
                            .font(.caption)
                    }
                    .foregroundStyle(phase.color)
                }

                // Stats
                HStack(spacing: 16) {
                    // Training days
                    Label {
                        Text("\(week.trainingDays) days")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "calendar")
                    }

                    // Intensity modifier
                    if week.intensityModifier != 1.0 {
                        Label {
                            Text(String(format: "%.0f%%", week.intensityModifier * 100))
                                .font(.caption)
                        } icon: {
                            Image(systemName: week.intensityModifier > 1.0 ? "arrow.up" : "arrow.down")
                        }
                        .foregroundStyle(week.intensityModifier > 1.0 ? .orange : .green)
                    }

                    // Deload indicator
                    if week.isDeload {
                        Label {
                            Text("Deload")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "arrow.down.circle.fill")
                        }
                        .foregroundStyle(.green)
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
    }
}

#Preview("Regular Week") {
    WeekCard(
        week: ProgramWeek(
            weekNumber: 3,
            name: "Hypertrophy Phase",
            phaseTag: .hypertrophy,
            intensityModifier: 1.05,
            volumeModifier: 1.0
        )
    )
    .padding()
}

#Preview("Current Week - Deload") {
    WeekCard(
        week: ProgramWeek(
            weekNumber: 4,
            name: "Deload Week",
            phaseTag: .deload,
            intensityModifier: 0.6,
            volumeModifier: 0.8,
            isDeload: true
        ),
        isCurrentWeek: true
    )
    .padding()
}
