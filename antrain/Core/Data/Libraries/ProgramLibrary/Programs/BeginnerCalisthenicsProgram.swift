//
//  BeginnerCalisthenicsProgram.swift
//  antrain
//
//  Created by Gemini on 2025-11-12.
//

import Foundation

struct BeginnerCalisthenicsProgram {
    static let all: [ProgramDTO] = [calisthenicsBeginner]

    static let calisthenicsBeginner = ProgramDTO(
        name: "Beginner Calisthenics",
        description: "A 3-day beginner-friendly calisthenics program focusing on full-body workouts.",
        category: .calisthenics,
        difficulty: .beginner,
        totalDays: 3,
        days: [
            DayDTO(dayNumber: 1, name: "Full Body Workout", templateName: "Calisthenics - Full Body"),
            DayDTO(dayNumber: 2, name: "Rest Day"),
            DayDTO(dayNumber: 3, name: "Full Body Workout", templateName: "Calisthenics - Full Body")
        ]
    )
}
