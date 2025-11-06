//
//  WeekProgressionPattern.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation

/// Weekly progression pattern for periodization
enum WeekProgressionPattern: String, Codable, CaseIterable, Sendable {
    case linear
    case wave
    case threeOneDeload
    case fourOneDeload
    case custom

    /// Localized display name
    var displayName: String {
        switch self {
        case .linear:
            return String(localized: "Linear Progression", comment: "Progression pattern: Linear")
        case .wave:
            return String(localized: "Wave Progression", comment: "Progression pattern: Wave")
        case .threeOneDeload:
            return String(localized: "3 Weeks Up, 1 Deload", comment: "Progression pattern: 3-1 Deload")
        case .fourOneDeload:
            return String(localized: "4 Weeks Up, 1 Deload", comment: "Progression pattern: 4-1 Deload")
        case .custom:
            return String(localized: "Custom", comment: "Progression pattern: Custom")
        }
    }

    /// Description of the pattern
    var description: String {
        switch self {
        case .linear:
            return String(localized: "Consistent weekly increase in intensity",
                         comment: "Linear progression description")
        case .wave:
            return String(localized: "Alternating high and low intensity weeks",
                         comment: "Wave progression description")
        case .threeOneDeload:
            return String(localized: "3 progressive weeks followed by 1 deload week",
                         comment: "3-1 deload description")
        case .fourOneDeload:
            return String(localized: "4 progressive weeks followed by 1 deload week",
                         comment: "4-1 deload description")
        case .custom:
            return String(localized: "User-defined progression pattern",
                         comment: "Custom progression description")
        }
    }

    /// Calculate intensity modifier for a given week number
    /// - Parameters:
    ///   - weekNumber: Week number (1-indexed)
    ///   - baseIncrement: Base weekly increment (default 0.025 = 2.5%)
    /// - Returns: Intensity modifier (1.0 = 100%, 1.025 = 102.5%, etc.)
    func intensityModifier(for weekNumber: Int, baseIncrement: Double = 0.025) -> Double {
        switch self {
        case .linear:
            return 1.0 + (Double(weekNumber - 1) * baseIncrement)

        case .wave:
            // Week 1: 1.0, Week 2: 1.05, Week 3: 0.95, Week 4: 1.10, Week 5: 1.0, Week 6: 1.15
            let cycle = (weekNumber - 1) % 3
            let cycleNumber = (weekNumber - 1) / 3

            switch cycle {
            case 0: return 1.0 + (Double(cycleNumber) * baseIncrement * 2)
            case 1: return 1.0 + (Double(cycleNumber) * baseIncrement * 2) + 0.05
            case 2: return 1.0 + (Double(cycleNumber) * baseIncrement * 2) - 0.05
            default: return 1.0
            }

        case .threeOneDeload:
            let cycle = (weekNumber - 1) % 4
            let cycleNumber = (weekNumber - 1) / 4
            let baseLine = 1.0 + (Double(cycleNumber) * 4 * baseIncrement)

            if cycle == 3 {
                // Deload week
                return baseLine * 0.6
            } else {
                return baseLine + (Double(cycle) * baseIncrement)
            }

        case .fourOneDeload:
            let cycle = (weekNumber - 1) % 5
            let cycleNumber = (weekNumber - 1) / 5
            let baseLine = 1.0 + (Double(cycleNumber) * 5 * baseIncrement)

            if cycle == 4 {
                // Deload week
                return baseLine * 0.6
            } else {
                return baseLine + (Double(cycle) * baseIncrement)
            }

        case .custom:
            // For custom, return linear as default
            return 1.0 + (Double(weekNumber - 1) * baseIncrement)
        }
    }

    /// Check if a given week is a deload week
    func isDeloadWeek(_ weekNumber: Int) -> Bool {
        switch self {
        case .threeOneDeload:
            return (weekNumber - 1) % 4 == 3
        case .fourOneDeload:
            return (weekNumber - 1) % 5 == 4
        case .linear, .wave, .custom:
            return false
        }
    }
}
