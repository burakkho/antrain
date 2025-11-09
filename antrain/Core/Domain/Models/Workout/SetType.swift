//
//  SetType.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Set type classification for workout tracking
//

import Foundation

/// Set type classification (normal, warmup, dropset, failure, custom)
enum SetType: String, Codable, CaseIterable, Sendable {
    case normal
    case warmup
    case dropset
    case failure
    case custom

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .warmup: return "Warmup"
        case .dropset: return "Drop Set"
        case .failure: return "To Failure"
        case .custom: return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .normal: return ""
        case .warmup: return "🔥"
        case .dropset: return "📉"
        case .failure: return "💪"
        case .custom: return "⭐"
        }
    }

    var shortLabel: String {
        switch self {
        case .normal: return ""
        case .warmup: return "W"
        case .dropset: return "D"
        case .failure: return "F"
        case .custom: return "C"
        }
    }

    /// Parse CSV set_type string to SetType
    /// Handles various formats: "normal", "warmup", "Diamond", etc.
    nonisolated static func from(string: String?) -> SetType {
        guard let type = string?.lowercased().trimmingCharacters(in: .whitespaces) else {
            return .normal
        }

        switch type {
        case "normal", "": return .normal
        case "warmup", "warm up", "warm-up": return .warmup
        case "dropset", "drop set", "drop-set": return .dropset
        case "failure", "to failure": return .failure
        default: return .custom  // Any custom types from various apps
        }
    }
}
