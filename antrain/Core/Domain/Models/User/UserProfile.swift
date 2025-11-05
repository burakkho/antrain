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
