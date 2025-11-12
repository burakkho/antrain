//
//  StartingStrengthProgram.swift
//  antrain
//
//  Created by Gemini on 2025-11-12.
//

import Foundation

struct StartingStrengthProgram {
    static let all: [ProgramDTO] = [startingStrength]

    static let startingStrength = ProgramDTO(
        name: "Starting Strength",
        description: "A 12-week beginner strength program focusing on linear progression with compound lifts.",
        category: .strength,
        difficulty: .beginner,
        totalDays: 84, // 12 weeks
        days: {
            var days: [DayDTO] = []
            var workoutType: String = "A" // Start with Workout A

            for week in 0..<12 {
                let weekStartDay = week * 7
                
                // Day 1 (e.g., Monday)
                days.append(DayDTO(dayNumber: weekStartDay + 1, templateName: "Starting Strength \(workoutType)"))
                // Day 2 (e.g., Tuesday) - Rest
                days.append(DayDTO(dayNumber: weekStartDay + 2))
                // Day 3 (e.g., Wednesday)
                days.append(DayDTO(dayNumber: weekStartDay + 3, templateName: "Starting Strength \(workoutType == "A" ? "B" : "A")"))
                // Day 4 (e.g., Thursday) - Rest
                days.append(DayDTO(dayNumber: weekStartDay + 4))
                // Day 5 (e.g., Friday)
                days.append(DayDTO(dayNumber: weekStartDay + 5, templateName: "Starting Strength \(workoutType)"))
                // Day 6 & 7 (e.g., Weekend) - Rest
                days.append(DayDTO(dayNumber: weekStartDay + 6))
                days.append(DayDTO(dayNumber: weekStartDay + 7))

                // Alternate for the next week
                workoutType = (workoutType == "A") ? "B" : "A"
            }
            return days
        }()
    )
}
