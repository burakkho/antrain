//
//  DifficultyLevel.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Training program difficulty level
enum DifficultyLevel: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced

    /// Localized display name
    var displayName: String {
        switch self {
        case .beginner:
            return String(localized: "Beginner", comment: "Difficulty level: Beginner")
        case .intermediate:
            return String(localized: "Intermediate", comment: "Difficulty level: Intermediate")
        case .advanced:
            return String(localized: "Advanced", comment: "Difficulty level: Advanced")
        }
    }

    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .beginner:
            return "1.circle.fill"
        case .intermediate:
            return "2.circle.fill"
        case .advanced:
            return "3.circle.fill"
        }
    }

    /// Numeric representation (for sorting)
    var level: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
}
