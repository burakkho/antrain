//
//  FiveThreeOneProgram.swift
//  antrain
//
//  Created by Gemini on 2025-11-12.
//

import Foundation

struct FiveThreeOneProgram {
    static let all: [ProgramDTO] = [fiveThreeOne]

    static let fiveThreeOne = ProgramDTO(
        name: "Jim Wendler's 5/3/1",
        description: "A proven strength program based on periodic progression, focusing on four main lifts.",
        category: .strength,
        difficulty: .advanced,
        totalDays: 7, // Weekly cycle
        days: [
            DayDTO(dayNumber: 1, name: "5/3/1 Squat", templateName: "531 Squat"),
            DayDTO(dayNumber: 2, name: "5/3/1 Bench", templateName: "531 Bench"),
            DayDTO(dayNumber: 3, name: "Rest Day"),
            DayDTO(dayNumber: 4, name: "5/3/1 Deadlift", templateName: "531 Deadlift"),
            DayDTO(dayNumber: 5, name: "5/3/1 Press", templateName: "531 Press"),
            DayDTO(dayNumber: 6, name: "Rest Day"),
            DayDTO(dayNumber: 7, name: "Rest Day")
        ]
    )
}
