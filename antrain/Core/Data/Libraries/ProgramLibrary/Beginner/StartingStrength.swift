//
//  StartingStrength.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Starting Strength - Classic beginner strength program
/// 3 days/week, alternating A/B workouts, linear progression
func startingStrengthProgram() -> ProgramDTO {
    var weeks: [WeekDTO] = []

    // 4-week program with linear progression
    for weekNum in 1...4 {
        let intensityMod = 1.0 + (Double(weekNum - 1) * 0.05) // 5% per week
        let isDeload = (weekNum == 4) // Deload on week 4

        let days: [DayDTO] = [
            // Monday - Workout A
            DayDTO(
                dayOfWeek: 2,
                name: "Workout A",
                templateName: "Starting Strength A"
            ),
            // Wednesday - Workout B
            DayDTO(
                dayOfWeek: 4,
                name: "Workout B",
                templateName: "Starting Strength B"
            ),
            // Friday - Workout A
            DayDTO(
                dayOfWeek: 6,
                name: "Workout A",
                templateName: "Starting Strength A"
            )
        ]

        weeks.append(WeekDTO(
            weekNumber: weekNum,
            name: isDeload ? "Deload Week" : "Week \(weekNum)",
            phaseTag: isDeload ? .deload : .strength,
            intensityModifier: isDeload ? 0.8 : intensityMod,
            volumeModifier: isDeload ? 0.7 : 1.0,
            isDeload: isDeload,
            notes: isDeload ? "Reduce weight by 20-30% and focus on form" : nil,
            days: days
        ))
    }

    return ProgramDTO(
        name: "Starting Strength",
        description: "The classic beginner program by Mark Rippetoe. Focus on the main compound lifts with linear progression. Perfect for building a foundation of strength.",
        category: .strengthTraining,
        difficulty: .beginner,
        durationWeeks: 4,
        progressionPattern: .linear,
        weeks: weeks
    )
}
