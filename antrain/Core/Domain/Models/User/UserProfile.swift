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

    // AI Coach Onboarding Fields
    /// User's fitness experience level
    var fitnessLevel: FitnessLevel?
    /// User's fitness goals (can have multiple)
    var fitnessGoals: [FitnessGoal] = []
    /// How many days per week user can train
    var weeklyWorkoutFrequency: Int?
    /// Available equipment for workouts
    var availableEquipment: Equipment?

    // Training Programs v2.0 Additions
    /// Currently active training program (nullify on delete to prevent orphan reference)
    @Relationship(deleteRule: .nullify)
    var activeProgram: TrainingProgram?
    /// Date when the active program was started
    var activeProgramStartDate: Date?
    /// Current day number in the active program (1-indexed, 1-totalDays)
    var currentDayNumber: Int?

    // Onboarding state
    /// Track if user has completed initial onboarding wizard
    var hasCompletedInitialOnboarding: Bool = false

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

    // MARK: - Fitness Level Enum

    /// User's fitness experience level
    enum FitnessLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"

        var localizedName: LocalizedStringKey {
            switch self {
            case .beginner:
                return "Beginner"
            case .intermediate:
                return "Intermediate"
            case .advanced:
                return "Advanced"
            }
        }

        var displayName: String {
            switch self {
            case .beginner:
                return String(localized: "Beginner")
            case .intermediate:
                return String(localized: "Intermediate")
            case .advanced:
                return String(localized: "Advanced")
            }
        }

        var description: String {
            switch self {
            case .beginner:
                return String(localized: "0-1 year of training experience")
            case .intermediate:
                return String(localized: "1-3 years of training experience")
            case .advanced:
                return String(localized: "3+ years of training experience")
            }
        }
    }

    // MARK: - Fitness Goal Enum

    /// User's fitness goals (can have multiple)
    enum FitnessGoal: String, Codable, CaseIterable {
        case muscleGain = "Muscle Gain"
        case fatLoss = "Fat Loss"
        case strength = "Strength"
        case endurance = "Endurance"

        var localizedName: LocalizedStringKey {
            switch self {
            case .muscleGain:
                return "Muscle Gain"
            case .fatLoss:
                return "Fat Loss"
            case .strength:
                return "Strength"
            case .endurance:
                return "Endurance"
            }
        }

        var displayName: String {
            switch self {
            case .muscleGain:
                return String(localized: "Muscle Gain")
            case .fatLoss:
                return String(localized: "Fat Loss")
            case .strength:
                return String(localized: "Strength")
            case .endurance:
                return String(localized: "Endurance")
            }
        }

        var icon: String {
            switch self {
            case .muscleGain:
                return "💪"
            case .fatLoss:
                return "🔥"
            case .strength:
                return "⚡️"
            case .endurance:
                return "🏃"
            }
        }
    }

    // MARK: - Equipment Enum

    /// Available equipment for workouts
    enum Equipment: String, Codable, CaseIterable {
        case gym = "Gym"
        case home = "Home"
        case minimal = "Minimal"

        var localizedName: LocalizedStringKey {
            switch self {
            case .gym:
                return "Gym"
            case .home:
                return "Home"
            case .minimal:
                return "Minimal"
            }
        }

        var displayName: String {
            switch self {
            case .gym:
                return String(localized: "Gym")
            case .home:
                return String(localized: "Home")
            case .minimal:
                return String(localized: "Minimal")
            }
        }

        var description: String {
            switch self {
            case .gym:
                return String(localized: "Full gym access")
            case .home:
                return String(localized: "Home equipment (dumbbells, bench, etc.)")
            case .minimal:
                return String(localized: "Bodyweight only or minimal equipment")
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
        dailyFatsGoal: Double? = nil,
        fitnessLevel: FitnessLevel? = nil,
        fitnessGoals: [FitnessGoal]? = nil,
        weeklyWorkoutFrequency: Int? = nil,
        availableEquipment: Equipment? = nil
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
        if let fitnessLevel = fitnessLevel {
            self.fitnessLevel = fitnessLevel
        }
        if let fitnessGoals = fitnessGoals {
            self.fitnessGoals = fitnessGoals
        }
        if let weeklyWorkoutFrequency = weeklyWorkoutFrequency {
            self.weeklyWorkoutFrequency = weeklyWorkoutFrequency
        }
        if let availableEquipment = availableEquipment {
            self.availableEquipment = availableEquipment
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
        self.currentDayNumber = 1
        self.updatedAt = Date()

        // Mark program as used
        program.markAsUsed()
    }

    /// Deactivate the current training program
    func deactivateProgram() {
        self.activeProgram = nil
        self.activeProgramStartDate = nil
        self.currentDayNumber = nil
        self.updatedAt = Date()
    }

    /// Get current day's workout from the active program
    /// - Returns: ProgramDay for current day number, or nil if no active program
    func getTodaysWorkout() -> ProgramDay? {
        guard let activeProgram = activeProgram,
              let dayNumber = currentDayNumber else {
            return nil
        }

        return activeProgram.day(number: dayNumber)
    }

    /// Progress to the next day in the active program
    /// - Returns: True if progressed, false if program is complete
    @discardableResult
    func progressToNextDay() -> Bool {
        guard let current = currentDayNumber,
              let program = activeProgram else {
            return false
        }

        // Don't exceed program duration
        if current < program.totalDays {
            currentDayNumber = current + 1
            updatedAt = Date()
            return true
        } else {
            // Program completed
            return false
        }
    }

    /// Check if the active program is completed
    var isProgramCompleted: Bool {
        guard let currentDay = currentDayNumber,
              let program = activeProgram else {
            return false
        }
        return currentDay > program.totalDays
    }

    /// Get the current day from the active program
    var currentProgramDay: ProgramDay? {
        guard let dayNumber = currentDayNumber,
              let program = activeProgram else {
            return nil
        }
        return program.day(number: dayNumber)
    }

    /// Calculate program progress percentage (0.0 - 1.0)
    var programProgress: Double {
        guard let currentDay = currentDayNumber,
              let program = activeProgram else {
            return 0.0
        }
        return Double(currentDay - 1) / Double(program.totalDays)
    }
}

// MARK: - AI Coach Extensions

extension UserProfile {
    /// Check if user has completed AI onboarding (has minimum required info)
    var hasCompletedOnboarding: Bool {
        return fitnessLevel != nil && !fitnessGoals.isEmpty
    }

    /// Check if user needs AI onboarding
    var needsAIOnboarding: Bool {
        return !hasCompletedOnboarding
    }

    /// Get onboarding completion percentage
    var onboardingProgress: Double {
        var completedFields = 0
        let totalFields = 4

        if fitnessLevel != nil { completedFields += 1 }
        if !fitnessGoals.isEmpty { completedFields += 1 }
        if weeklyWorkoutFrequency != nil { completedFields += 1 }
        if availableEquipment != nil { completedFields += 1 }

        return Double(completedFields) / Double(totalFields)
    }
}
