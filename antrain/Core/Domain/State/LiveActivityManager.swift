//
//  LiveActivityManager.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Manages Live Activity state change notifications
/// Duration is now handled by Apple's native Text(timerInterval:) component
/// Separated from ViewModel for Single Responsibility Principle
@MainActor
final class LiveActivityManager {
    // MARK: - Properties

    /// Callback to notify when state should be updated (e.g., for Live Activity)
    var onStateChanged: (() -> Void)?

    // MARK: - State Management

    /// Notify state change (for manual updates)
    /// Call this when meaningful workout events occur (set completion, exercise change, etc.)
    func notifyStateChanged() {
        onStateChanged?()
    }
}
