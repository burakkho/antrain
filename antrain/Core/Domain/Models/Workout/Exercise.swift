//
//  Exercise.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Egzersiz kütüphanesi (preset + custom)
@Model
final class Exercise: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: ExerciseCategory
    var muscleGroups: [MuscleGroup]
    var equipment: Equipment
    var isCustom: Bool
    var version: Int

    init(
        name: String,
        category: ExerciseCategory,
        muscleGroups: [MuscleGroup],
        equipment: Equipment,
        isCustom: Bool = false,
        version: Int = 1
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.equipment = equipment
        self.isCustom = isCustom
        self.version = version
    }
}

// MARK: - Exercise Category
enum ExerciseCategory: String, Codable, Sendable {
    case barbell
    case dumbbell
    case bodyweight
    case weightlifting
    case machine
    case cable
    case cardio
    case metcon
}

// MARK: - Muscle Group
enum MuscleGroup: String, Codable, Sendable, CaseIterable {
    case chest
    case back
    case shoulders
    case traps
    case biceps
    case triceps
    case quads
    case hamstrings
    case glutes
    case calves
    case core
    case fullBody
}

// MARK: - Equipment
enum Equipment: String, Codable, Sendable {
    case barbell
    case dumbbell
    case none
    case machine
    case cable
    case kettlebell
    case plate
    case band
}

// MARK: - Validation
extension Exercise {
    func validate() throws {
        guard !name.isEmpty else {
            throw ValidationError.emptyField("Exercise name")
        }

        guard name.count <= 100 else {
            throw ValidationError.invalidValue("Exercise name must be 100 characters or less")
        }

        guard !muscleGroups.isEmpty else {
            throw ValidationError.businessRuleViolation("Exercise must target at least one muscle group")
        }
    }
}

// MARK: - Display Helpers
extension Exercise {
    var muscleGroupsDisplay: String {
        muscleGroups.map { $0.rawValue.capitalized }.joined(separator: ", ")
    }

    var categoryDisplay: String {
        category.rawValue.capitalized
    }
}

// MARK: - Validation Error
enum ValidationError: LocalizedError {
    case emptyField(String)
    case invalidValue(String)
    case businessRuleViolation(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field) cannot be empty"
        case .invalidValue(let message):
            return "Invalid value: \(message)"
        case .businessRuleViolation(let message):
            return message
        }
    }
}
