//
//  OneRepMaxCalculator.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// One Rep Max (1RM) calculator using various formulas
/// Default: Brzycki formula (most accurate for 1-10 reps)
struct OneRepMaxCalculator {
    /// Calculate estimated 1RM using Brzycki formula
    /// Formula: 1RM = weight × (36 / (37 - reps))
    ///
    /// - Parameters:
    ///   - weight: Weight lifted (in kg)
    ///   - reps: Number of reps performed
    /// - Returns: Estimated 1RM in kg
    ///
    /// Notes:
    /// - Most accurate for 1-10 reps
    /// - For 1 rep, returns actual weight
    /// - For >12 reps, accuracy decreases (endurance vs strength)
    nonisolated static func brzycki(weight: Double, reps: Int) -> Double {
        // Edge case: 1 rep = actual weight
        guard reps > 1 else {
            return weight
        }

        // Brzycki formula breaks down for high reps (>12)
        // Cap at 12 for reasonable estimates
        let cappedReps = min(reps, 12)

        // Brzycki: 1RM = weight × (36 / (37 - reps))
        let oneRM = weight * (36.0 / (37.0 - Double(cappedReps)))

        return oneRM
    }

    /// Calculate estimated 1RM using Epley formula
    /// Formula: 1RM = weight × (1 + reps/30)
    ///
    /// Alternative formula, slightly different results
    /// Generally gives higher estimates than Brzycki
    nonisolated static func epley(weight: Double, reps: Int) -> Double {
        guard reps > 1 else {
            return weight
        }

        let cappedReps = min(reps, 12)
        let oneRM = weight * (1.0 + Double(cappedReps) / 30.0)

        return oneRM
    }

    /// Calculate percentage of 1RM for a given weight
    /// - Parameters:
    ///   - weight: Weight to check
    ///   - oneRM: Estimated or known 1RM
    /// - Returns: Percentage (0.0 - 1.0)
    nonisolated static func percentageOf1RM(weight: Double, oneRM: Double) -> Double {
        guard oneRM > 0 else { return 0.0 }
        return weight / oneRM
    }

    /// Calculate recommended reps for a given percentage of 1RM
    /// Based on typical strength training zones
    /// - Parameter percentage: Percentage of 1RM (0.0 - 1.0)
    /// - Returns: Recommended rep range
    nonisolated static func recommendedReps(for percentage: Double) -> ClosedRange<Int> {
        switch percentage {
        case 0.9...1.0:   // 90-100% 1RM
            return 1...3   // Max strength
        case 0.8..<0.9:   // 80-90% 1RM
            return 3...6   // Strength
        case 0.7..<0.8:   // 70-80% 1RM
            return 6...10  // Hypertrophy
        case 0.6..<0.7:   // 60-70% 1RM
            return 10...15 // Hypertrophy/Endurance
        default:          // <60% 1RM
            return 15...20 // Endurance
        }
    }
}

// MARK: - Convenience Extensions

extension WorkoutSet {
    /// Calculate estimated 1RM for this set using Brzycki formula
    /// Returns nil if weight or reps is 0
    nonisolated var estimated1RM: Double? {
        guard weight > 0, reps > 0 else { return nil }
        return OneRepMaxCalculator.brzycki(weight: weight, reps: reps)
    }

    /// Check if this set is a PR candidate (valid for PR tracking)
    /// PR tracking only for sets with weight and reps (not cardio/timed sets)
    nonisolated var isPRCandidate: Bool {
        return weight > 0 && reps > 0
    }
}
