//
//  FiveThreeOneBBB.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// 5/3/1 Boring But Big - Jim Wendler's classic program
/// 4 days/week with main lifts + high volume accessories
func fiveThreeOneBBBProgram() -> ProgramDTO {
    var weeks: [WeekDTO] = []

    // 4 weeks = 1 full cycle
    let weekNames = ["5/5/5", "3/3/3", "5/3/1", "Deload"]

    for weekNum in 1...4 {
        let isDeload = (weekNum == 4)

        let days: [DayDTO] = [
            DayDTO(dayOfWeek: 2, name: "Squat Day", templateName: "531 Squat"),
            DayDTO(dayOfWeek: 3, name: "Bench Day", templateName: "531 Bench"),
            DayDTO(dayOfWeek: 5, name: "Deadlift Day", templateName: "531 Deadlift"),
            DayDTO(dayOfWeek: 6, name: "Press Day", templateName: "531 Press")
        ]

        weeks.append(WeekDTO(
            weekNumber: weekNum,
            name: weekNames[weekNum - 1],
            phaseTag: isDeload ? .deload : .strength,
            intensityModifier: isDeload ? 0.4 : 1.0 + Double(weekNum - 1) * 0.05,
            volumeModifier: isDeload ? 0.5 : 1.0,
            isDeload: isDeload,
            days: days
        ))
    }

    return ProgramDTO(
        name: "5/3/1 Boring But Big",
        description: "Jim Wendler's 5/3/1 with BBB assistance work. Build strength with main lifts, add mass with 5x10 accessory work. Proven program for all levels.",
        category: .powerlifting,
        difficulty: .intermediate,
        durationWeeks: 4,
        progressionPattern: .fourOneDeload,
        weeks: weeks
    )
}
