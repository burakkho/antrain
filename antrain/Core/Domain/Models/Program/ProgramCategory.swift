//
//  ProgramCategory.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Training program category classification
enum ProgramCategory: String, Codable, CaseIterable, Sendable {
    case powerlifting
    case bodybuilding
    case strengthTraining
    case crossfit
    case generalFitness
    case sportSpecific

    /// Localized display name
    var displayName: String {
        switch self {
        case .powerlifting:
            return String(localized: "Powerlifting", comment: "Program category: Powerlifting")
        case .bodybuilding:
            return String(localized: "Bodybuilding", comment: "Program category: Bodybuilding")
        case .strengthTraining:
            return String(localized: "Strength Training", comment: "Program category: Strength Training")
        case .crossfit:
            return String(localized: "CrossFit", comment: "Program category: CrossFit")
        case .generalFitness:
            return String(localized: "General Fitness", comment: "Program category: General Fitness")
        case .sportSpecific:
            return String(localized: "Sport Specific", comment: "Program category: Sport Specific")
        }
    }

    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .powerlifting:
            return "figure.strengthtraining.traditional"
        case .bodybuilding:
            return "figure.strengthtraining.functional"
        case .strengthTraining:
            return "dumbbell.fill"
        case .crossfit:
            return "figure.mixed.cardio"
        case .generalFitness:
            return "figure.walk"
        case .sportSpecific:
            return "sportscourt.fill"
        }
    }
}
