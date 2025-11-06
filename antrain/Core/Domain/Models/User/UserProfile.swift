//
//  UserProfile.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData
import SwiftUI

/// User profile model
/// Contains user settings and preferences
@Model
final class UserProfile: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var height: Double? // in centimeters
    var gender: Gender?
    var dateOfBirth: Date? // for age calculation in TDEE
    var activityLevel: ActivityLevel? // for TDEE calculation
    var dailyCalorieGoal: Double
    var dailyProteinGoal: Double
    var dailyCarbsGoal: Double
    var dailyFatsGoal: Double
    var createdAt: Date
    var updatedAt: Date

    // Training Programs v2.0 Additions
    /// Currently active training program (nullify on delete to prevent orphan reference)
    @Relationship(deleteRule: .nullify)
    var activeProgram: TrainingProgram?
    /// Date when the active program was started
    var activeProgramStartDate: Date?
    /// Current week number in the active program (1-indexed)
    var currentWeekNumber: Int?

    // MARK: - Gender Enum

    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        case preferNotToSay = "Prefer not to say"

        var localizedName: LocalizedStringKey {
            switch self {
            case .male:
                return "Male"
            case .female:
                return "Female"
            case .other:
                return "Other"
            case .preferNotToSay:
                return "Prefer not to say"
            }
        }

        var displayName: String {
            switch self {
            case .male:
                return String(localized: "Male")
            case .female:
                return String(localized: "Female")
            case .other:
                return String(localized: "Other")
            case .preferNotToSay:
                return String(localized: "Prefer not to say")
            }
        }
    }

    // MARK: - Activity Level Enum

    /// Physical activity levels (mirrors TDEECalculator.ActivityLevel)
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extraActive = "Extra Active"

        var localizedName: LocalizedStringKey {
            switch self {
            case .sedentary:
                return "Sedentary"
            case .lightlyActive:
                return "Lightly Active"
            case .moderatelyActive:
                return "Moderately Active"
            case .veryActive:
                return "Very Active"
            case .extraActive:
                return "Extra Active"
            }
        }

        var displayName: String {
            switch self {
            case .sedentary:
                return String(localized: "Sedentary")
            case .lightlyActive:
                return String(localized: "Lightly Active")
            case .moderatelyActive:
                return String(localized: "Moderately Active")
            case .veryActive:
                return String(localized: "Very Active")
            case .extraActive:
                return String(localized: "Extra Active")
            }
        }
    }

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \BodyweightEntry.userProfile)
    var bodyweightEntries: [BodyweightEntry] = []

    // MARK: - Initialization

    init(
        name: String = "",
        height: Double? = nil,
        gender: Gender? = nil,
        dateOfBirth: Date? = nil,
        activityLevel: ActivityLevel? = nil,
        dailyCalorieGoal: Double = 2000,
        dailyProteinGoal: Double = 150,
        dailyCarbsGoal: Double = 200,
        dailyFatsGoal: Double = 65
    ) {
        self.id = UUID()
        self.name = name
        self.height = height
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.activityLevel = activityLevel
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyFatsGoal = dailyFatsGoal
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Calculate age from date of birth
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }

    /// Get most recent bodyweight entry
    var currentBodyweight: BodyweightEntry? {
        bodyweightEntries
            .sorted { $0.date > $1.date }
            .first
    }

    /// Get bodyweight entries sorted by date (newest first)
    var sortedBodyweightEntries: [BodyweightEntry] {
        bodyweightEntries.sorted { $0.date > $1.date }
    }

    // MARK: - Methods

    /// Update profile data and set updatedAt
    func update(
        name: String? = nil,
        height: Double? = nil,
        gender: Gender? = nil,
        dateOfBirth: Date? = nil,
        activityLevel: ActivityLevel? = nil,
        dailyCalorieGoal: Double? = nil,
        dailyProteinGoal: Double? = nil,
        dailyCarbsGoal: Double? = nil,
        dailyFatsGoal: Double? = nil
    ) {
        if let name = name {
            self.name = name
        }
        if let height = height {
            self.height = height
        }
        if let gender = gender {
            self.gender = gender
        }
        if let dateOfBirth = dateOfBirth {
            self.dateOfBirth = dateOfBirth
        }
        if let activityLevel = activityLevel {
            self.activityLevel = activityLevel
        }
        if let dailyCalorieGoal = dailyCalorieGoal {
            self.dailyCalorieGoal = dailyCalorieGoal
        }
        if let dailyProteinGoal = dailyProteinGoal {
            self.dailyProteinGoal = dailyProteinGoal
        }
        if let dailyCarbsGoal = dailyCarbsGoal {
            self.dailyCarbsGoal = dailyCarbsGoal
        }
        if let dailyFatsGoal = dailyFatsGoal {
            self.dailyFatsGoal = dailyFatsGoal
        }
        self.updatedAt = Date()
    }

    /// Add a bodyweight entry
    func addBodyweightEntry(_ entry: BodyweightEntry) {
        bodyweightEntries.append(entry)
        updatedAt = Date()
    }

    /// Remove a bodyweight entry
    func removeBodyweightEntry(_ entry: BodyweightEntry) {
        bodyweightEntries.removeAll { $0.id == entry.id }
        updatedAt = Date()
    }

    /// Validate profile data
    func validate() throws {
        // Validate nutrition goals are positive
        guard dailyCalorieGoal > 0 else {
            throw ValidationError.businessRuleViolation("Daily calorie goal must be greater than 0")
        }
        guard dailyProteinGoal >= 0 else {
            throw ValidationError.businessRuleViolation("Daily protein goal cannot be negative")
        }
        guard dailyCarbsGoal >= 0 else {
            throw ValidationError.businessRuleViolation("Daily carbs goal cannot be negative")
        }
        guard dailyFatsGoal >= 0 else {
            throw ValidationError.businessRuleViolation("Daily fats goal cannot be negative")
        }
    }
}

// MARK: - Training Programs v2.0 Extensions

extension UserProfile {
    /// Activate a training program
    func activateProgram(_ program: TrainingProgram) {
        self.activeProgram = program
        self.activeProgramStartDate = Date()
        self.currentWeekNumber = 1
        self.updatedAt = Date()

        // Mark program as used
        program.markAsUsed()
    }

    /// Deactivate the current training program
    func deactivateProgram() {
        self.activeProgram = nil
        self.activeProgramStartDate = nil
        self.currentWeekNumber = nil
        self.updatedAt = Date()
    }

    /// Get today's workout from the active program
    /// - Returns: ProgramDay for today, or nil if no active program or no workout today
    func getTodaysWorkout() -> ProgramDay? {
        guard let activeProgram = activeProgram,
              let startDate = activeProgramStartDate else {
            return nil
        }

        let calendar = Calendar.current
        let today = Date()

        // Calculate days since program started
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0

        // Calculate current week number (1-indexed)
        let currentWeek = (daysSinceStart / 7) + 1

        // Get current day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
        let currentDayOfWeek = calendar.component(.weekday, from: today)

        // Find the workout for today
        return activeProgram.weeks
            .first { $0.weekNumber == currentWeek }?
            .days
            .first { $0.dayOfWeek == currentDayOfWeek }
    }

    /// Progress to the next week in the active program
    func progressToNextWeek() {
        guard let current = currentWeekNumber,
              let program = activeProgram else {
            return
        }

        // Don't exceed program duration
        if current < program.durationWeeks {
            currentWeekNumber = current + 1
            updatedAt = Date()
        }
    }

    /// Check if the active program is completed
    var isProgramCompleted: Bool {
        guard let currentWeek = currentWeekNumber,
              let program = activeProgram else {
            return false
        }
        return currentWeek > program.durationWeeks
    }

    /// Get the current week from the active program
    var currentProgramWeek: ProgramWeek? {
        guard let weekNumber = currentWeekNumber,
              let program = activeProgram else {
            return nil
        }
        return program.week(number: weekNumber)
    }

    /// Calculate program progress percentage (0.0 - 1.0)
    var programProgress: Double {
        guard let currentWeek = currentWeekNumber,
              let program = activeProgram else {
            return 0.0
        }
        return Double(currentWeek - 1) / Double(program.durationWeeks)
    }
}
