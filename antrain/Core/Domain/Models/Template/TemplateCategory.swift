//
//  TemplateCategory.swift
//  antrain
//
//  Created on 2025-11-03.
//

import Foundation
import SwiftUI

/// Categories for organizing workout templates
/// Each category has associated icon and color for visual organization
enum TemplateCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case calisthenics = "Calisthenics"
    case weightlifting = "Weightlifting"
    case beginner = "Beginner"
    case custom = "Custom"

    // MARK: - Display Properties

    /// Display name for the category
    var displayName: String {
        return rawValue
    }

    /// SF Symbol icon for the category
    var icon: String {
        switch self {
        case .strength:
            return "figure.strengthtraining.traditional"
        case .hypertrophy:
            return "figure.mind.and.body"
        case .calisthenics:
            return "figure.climbing"
        case .weightlifting:
            return "figure.mixed.cardio"
        case .beginner:
            return "star.fill"
        case .custom:
            return "folder.fill"
        }
    }

    /// Primary color for the category
    var color: Color {
        switch self {
        case .strength:
            return .red
        case .hypertrophy:
            return .blue
        case .calisthenics:
            return .green
        case .weightlifting:
            return .orange
        case .beginner:
            return .yellow
        case .custom:
            return .purple
        }
    }

    /// Description of what this category represents
    var description: String {
        switch self {
        case .strength:
            return "Heavy compounds, low reps, maximal strength"
        case .hypertrophy:
            return "Muscle growth focus, 8-12 rep ranges"
        case .calisthenics:
            return "Bodyweight exercises and skills"
        case .weightlifting:
            return "Olympic lifts and variations"
        case .beginner:
            return "Simple routines for those starting out"
        case .custom:
            return "Your own custom templates"
        }
    }

    // MARK: - Standard Configurations

    /// Standard set count for this category
    var defaultSetCount: Int {
        switch self {
        case .strength:
            return 4
        case .hypertrophy:
            return 3
        case .calisthenics:
            return 4
        case .weightlifting:
            return 5
        case .beginner:
            return 3
        case .custom:
            return 3
        }
    }

    /// Standard rep range for this category
    var defaultRepRange: (min: Int, max: Int) {
        switch self {
        case .strength:
            return (3, 5)
        case .hypertrophy:
            return (8, 12)
        case .calisthenics:
            return (8, 15)
        case .weightlifting:
            return (2, 3)
        case .beginner:
            return (8, 10)
        case .custom:
            return (8, 12)
        }
    }

    /// Minimum reps for default rep range
    var defaultRepRangeMin: Int {
        return defaultRepRange.min
    }

    /// Maximum reps for default rep range
    var defaultRepRangeMax: Int {
        return defaultRepRange.max
    }
}
