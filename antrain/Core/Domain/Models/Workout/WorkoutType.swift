//
//  WorkoutType.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Antrenman tiplerini tanımlar
/// - lifting: Real-time tracking (set-by-set)
/// - cardio: Post-workout quick log
/// - metcon: Post-workout quick log (MetCon/HIIT)
enum WorkoutType: String, Codable, Sendable {
    case lifting
    case cardio
    case metcon
}

// MARK: - Display Helpers
extension WorkoutType {
    var displayName: String {
        switch self {
        case .lifting:
            return "Lifting"
        case .cardio:
            return "Cardio"
        case .metcon:
            return "MetCon"
        }
    }

    var icon: String {
        switch self {
        case .lifting:
            return "dumbbell.fill"
        case .cardio:
            return "figure.run"
        case .metcon:
            return "flame.fill"
        }
    }
}
