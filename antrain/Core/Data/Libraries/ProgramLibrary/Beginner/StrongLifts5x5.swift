//
//  StrongLifts5x5.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// StrongLifts 5×5 - Simple but effective strength program
/// 3 days/week, alternating A/B workouts, 5 sets of 5 reps
func strongLifts5x5Program() -> ProgramDTO {
    var weeks: [WeekDTO] = []

    // 4-week program with linear progression
    for weekNum in 1...4 {
        let intensityMod = 1.0 + (Double(weekNum - 1) * 0.05)
        let isDeload = (weekNum == 4)

        // Alternate between A and B workouts
        let workoutA = "StrongLifts 5x5 A"
        let workoutB = "StrongLifts 5x5 B"

        let days: [DayDTO]
        if weekNum % 2 == 1 {
            // Week 1, 3, 5, etc.: A-B-A
            days = [
                DayDTO(
                    dayOfWeek: 2,
                    name: "Workout A",
                    templateName: workoutA
                ),
                DayDTO(
                    dayOfWeek: 4,
                    name: "Workout B",
                    templateName: workoutB
                ),
                DayDTO(
                    dayOfWeek: 6,
                    name: "Workout A",
                    templateName: workoutA
                )
            ]
        } else {
            // Week 2, 4, 6, etc.: B-A-B
            days = [
                DayDTO(
                    dayOfWeek: 2,
                    name: "Workout B",
                    templateName: workoutB
                ),
                DayDTO(
                    dayOfWeek: 4,
                    name: "Workout A",
                    templateName: workoutA
                ),
                DayDTO(
                    dayOfWeek: 6,
                    name: "Workout B",
                    templateName: workoutB
                )
            ]
        }

        weeks.append(WeekDTO(
            weekNumber: weekNum,
            name: isDeload ? "Deload Week" : "Week \(weekNum)",
            phaseTag: isDeload ? .deload : .strength,
            intensityModifier: isDeload ? 0.8 : intensityMod,
            volumeModifier: isDeload ? 0.6 : 1.0,
            isDeload: isDeload,
            notes: isDeload ? "Reduce to 3x5 instead of 5x5" : "Add 2.5-5kg per week when you complete all sets",
            days: days
        ))
    }

    return ProgramDTO(
        name: "StrongLifts 5×5",
        description: "Simple but brutally effective strength program. Three workouts per week, 5 sets of 5 reps on all main lifts. Add weight every session for consistent gains.",
        category: .strengthTraining,
        difficulty: .beginner,
        durationWeeks: 4,
        progressionPattern: .linear,
        weeks: weeks
    )
}
