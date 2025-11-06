//
//  PPL6Day.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// PPL 6-Day Split - Push/Pull/Legs twice per week
/// High volume bodybuilding program for hypertrophy
func ppl6DayProgram() -> ProgramDTO {
    var weeks: [WeekDTO] = []

    // 4-week program with wave loading
    for weekNum in 1...4 {
        let isDeload = (weekNum == 4)

        let intensityMod: Double
        if isDeload {
            intensityMod = 0.7
        } else {
            intensityMod = 1.0 + (Double(weekNum - 1) * 0.05)
        }

        let days: [DayDTO] = [
            // Monday - Push
            DayDTO(
                dayOfWeek: 2,
                name: "Push Day 1",
                templateName: "PPL Push",
                suggestedRPE: isDeload ? 6 : 8
            ),
            // Tuesday - Pull
            DayDTO(
                dayOfWeek: 3,
                name: "Pull Day 1",
                templateName: "PPL Pull",
                suggestedRPE: isDeload ? 6 : 8
            ),
            // Wednesday - Legs
            DayDTO(
                dayOfWeek: 4,
                name: "Leg Day 1",
                templateName: "PPL Legs",
                suggestedRPE: isDeload ? 6 : 8
            ),
            // Thursday - Push
            DayDTO(
                dayOfWeek: 5,
                name: "Push Day 2",
                templateName: "PPL Push",
                suggestedRPE: isDeload ? 6 : 8
            ),
            // Friday - Pull
            DayDTO(
                dayOfWeek: 6,
                name: "Pull Day 2",
                templateName: "PPL Pull",
                suggestedRPE: isDeload ? 6 : 8
            ),
            // Saturday - Legs
            DayDTO(
                dayOfWeek: 7,
                name: "Leg Day 2",
                templateName: "PPL Legs",
                suggestedRPE: isDeload ? 6 : 8
            )
        ]

        weeks.append(WeekDTO(
            weekNumber: weekNum,
            name: isDeload ? "Deload Week" : "Week \(weekNum)",
            phaseTag: isDeload ? .deload : .hypertrophy,
            intensityModifier: intensityMod,
            volumeModifier: isDeload ? 0.7 : 1.0,
            isDeload: isDeload,
            notes: isDeload ? "Cut volume in half, maintain intensity technique" : "Focus on mind-muscle connection and time under tension",
            days: days
        ))
    }

    return ProgramDTO(
        name: "PPL 6-Day Split",
        description: "Push/Pull/Legs split performed twice per week. High volume hypertrophy program ideal for intermediate to advanced lifters focused on muscle growth.",
        category: .bodybuilding,
        difficulty: .intermediate,
        durationWeeks: 4,
        progressionPattern: .fourOneDeload,
        weeks: weeks
    )
}
