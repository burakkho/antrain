//
//  PPLSplitProgram.swift
//  antrain
//
//  Created by Gemini on 2025-11-12.
//

import Foundation

struct PPLSplitProgram {
    static let all: [ProgramDTO] = [pplSplit]

    static let pplSplit = ProgramDTO(
        name: "Classic PPL Split",
        description: "An intermediate to advanced program for building muscle and strength, designed to be run 3 or 6 days a week.",
        category: .bodybuilding,
        difficulty: .intermediate,
        totalDays: 7, // Weekly cycle
        days: [
            DayDTO(dayNumber: 1, name: "Push Day", templateName: "PPL Push"),
            DayDTO(dayNumber: 2, name: "Pull Day", templateName: "PPL Pull"),
            DayDTO(dayNumber: 3, name: "Leg Day", templateName: "PPL Legs"),
            DayDTO(dayNumber: 4, name: "Rest Day"),
            DayDTO(dayNumber: 5, name: "Push Day", templateName: "PPL Push"),
            DayDTO(dayNumber: 6, name: "Pull Day", templateName: "PPL Pull"),
            DayDTO(dayNumber: 7, name: "Rest Day")
        ]
    )
}
