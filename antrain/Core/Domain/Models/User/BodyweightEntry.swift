//
//  BodyweightEntry.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData

/// Bodyweight entry model
/// Tracks user's bodyweight over time (always stored in kg)
@Model
final class BodyweightEntry: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var date: Date
    var weight: Double  // Always stored in kg
    var notes: String?

    // MARK: - Relationships

    var userProfile: UserProfile?

    // MARK: - Initialization

    init(
        date: Date = Date(),
        weight: Double,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.weight = weight
        self.notes = notes
    }

    // MARK: - Methods

    /// Validate bodyweight entry
    func validate() throws {
        guard weight > 0 else {
            throw ValidationError.businessRuleViolation("Weight must be greater than 0")
        }
        guard weight < 500 else {  // Reasonable upper limit in kg
            throw ValidationError.businessRuleViolation("Weight must be less than 500 kg")
        }
    }
}
