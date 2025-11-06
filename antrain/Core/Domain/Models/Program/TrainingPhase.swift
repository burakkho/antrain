//
//  TrainingPhase.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import Foundation
import SwiftUI

/// Training periodization phase
enum TrainingPhase: String, Codable, CaseIterable, Sendable {
    case hypertrophy
    case strength
    case peaking
    case deload
    case testing

    /// Localized display name
    var displayName: String {
        switch self {
        case .hypertrophy:
            return String(localized: "Hypertrophy", comment: "Training phase: Hypertrophy")
        case .strength:
            return String(localized: "Strength", comment: "Training phase: Strength")
        case .peaking:
            return String(localized: "Peaking", comment: "Training phase: Peaking")
        case .deload:
            return String(localized: "Deload", comment: "Training phase: Deload")
        case .testing:
            return String(localized: "Testing", comment: "Training phase: Testing")
        }
    }

    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .hypertrophy:
            return "figure.strengthtraining.functional"
        case .strength:
            return "figure.strengthtraining.traditional"
        case .peaking:
            return "arrow.up.circle.fill"
        case .deload:
            return "arrow.down.circle.fill"
        case .testing:
            return "flag.checkered"
        }
    }

    /// Color associated with phase
    @MainActor
    var color: Color {
        switch self {
        case .hypertrophy:
            return .blue
        case .strength:
            return .red
        case .peaking:
            return .orange
        case .deload:
            return .green
        case .testing:
            return .purple
        }
    }
}
