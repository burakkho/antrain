//
//  LiveActivityManager.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Manages Live Activity duration updates during workout sessions
/// Separated from ViewModel for Single Responsibility Principle
@MainActor
final class LiveActivityManager {
    // MARK: - Properties

    /// Callback to notify when state should be updated (e.g., for Live Activity)
    var onStateChanged: (() -> Void)?

    /// Timer for updating duration every second
    private var durationTimer: Timer?

    // MARK: - Timer Management

    /// Start timer to update duration every second
    /// Useful for Live Activity or other real-time UI updates
    func startDurationTimer() {
        // Stop any existing timer first
        stopDurationTimer()

        // Create timer that fires every second
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.onStateChanged?()
            }
        }

        // Ensure timer runs even during UI interactions
        if let timer = durationTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    /// Stop duration timer
    func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }

    /// Notify state change (for manual updates without timer)
    func notifyStateChanged() {
        onStateChanged?()
    }
}
