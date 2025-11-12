//
//  PowerliftingFocusProgram.swift
//  antrain
//
//  Created by Gemini on 2025-11-12.
//

import Foundation

struct PowerliftingFocusProgram {
    static let all: [ProgramDTO] = [powerliftingFocus]

    static let powerliftingFocus = ProgramDTO(
        name: "3-Day Powerlifting Focus",
        description: "A 3-day program designed to maximize strength in the three core lifts: Squat, Bench, and Deadlift.",
        category: .strength,
        difficulty: .advanced,
        totalDays: 7, // Weekly cycle
        days: [
            DayDTO(dayNumber: 1, name: "Squat Focus", templateName: "Powerlifting - Squat Day"),
            DayDTO(dayNumber: 2, name: "Rest Day"),
            DayDTO(dayNumber: 3, name: "Bench Focus", templateName: "Powerlifting - Bench Day"),
            DayDTO(dayNumber: 4, name: "Rest Day"),
            DayDTO(dayNumber: 5, name: "Deadlift Focus", templateName: "Powerlifting - Deadlift Day"),
            DayDTO(dayNumber: 6, name: "Rest Day"),
            DayDTO(dayNumber: 7, name: "Rest Day")
        ]
    )
}
