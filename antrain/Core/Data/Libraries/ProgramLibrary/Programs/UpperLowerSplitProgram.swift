//
//  UpperLowerSplitProgram.swift
//  antrain
//
//  Created by Gemini on 2025-11-12.
//

import Foundation

struct UpperLowerSplitProgram {
    static let all: [ProgramDTO] = [upperLowerSplit]

    static let upperLowerSplit = ProgramDTO(
        name: "4-Day Upper/Lower Split",
        description: "A balanced 4-day program focusing on training all muscle groups twice a week, ideal for both strength and hypertrophy.",
        category: .bodybuilding,
        difficulty: .intermediate,
        totalDays: 7, // Weekly cycle
        days: [
            DayDTO(dayNumber: 1, name: "Upper Body", templateName: "Upper/Lower - Upper"),
            DayDTO(dayNumber: 2, name: "Lower Body", templateName: "Upper/Lower - Lower"),
            DayDTO(dayNumber: 3, name: "Rest Day"),
            DayDTO(dayNumber: 4, name: "Upper Body", templateName: "Upper/Lower - Upper"),
            DayDTO(dayNumber: 5, name: "Lower Body", templateName: "Upper/Lower - Lower"),
            DayDTO(dayNumber: 6, name: "Rest Day"),
            DayDTO(dayNumber: 7, name: "Rest Day")
        ]
    )
}
