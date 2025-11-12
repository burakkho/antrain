//
//  HapticManager.swift
//  antrain
//
//  Created by Claude Code on 2025-11-09.
//

import UIKit
import SwiftUI

/// Centralized haptic feedback manager following Apple HIG best practices
///
/// Usage:
/// ```swift
/// HapticManager.shared.success()  // Task completed
/// HapticManager.shared.prAchieved()  // Celebrate PR!
/// ```
///
/// Features:
/// - User preference control via @AppStorage
/// - Prepared generators for reduced latency (<100ms)
/// - Fitness-specific contextual helpers
/// - Progressive intensity based on action magnitude
final class HapticManager {
    static let shared = HapticManager()

    // User preference (can be disabled in settings)
    private var hapticsEnabled: Bool {
        // Default to true if not set
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    // Reusable generators (prepared for low latency)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    init() {
        // Prepare generators on initialization for reduced latency
        prepare()
    }

    // MARK: - Preparation

    /// Prepare all generators for immediate use
    /// Call before predictable user interactions to reduce latency
    func prepare() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact Feedback

    /// Light impact for minor actions
    /// Use cases: add item, toggle, checkbox, light tap
    func light() {
        guard hapticsEnabled else { return }
        impactLight.impactOccurred()
        impactLight.prepare() // Re-prepare after use
    }

    /// Medium impact for standard actions
    /// Use cases: button press, mode switch, primary interaction
    func medium() {
        guard hapticsEnabled else { return }
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    /// Heavy impact for major actions
    /// Use cases: delete, reset, significant change, emphasis
    func heavy() {
        guard hapticsEnabled else { return }
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    /// Custom intensity impact (0.0 to 1.0)
    /// Use case: Progressive feedback based on value magnitude
    func impact(intensity: CGFloat) {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    // MARK: - Selection Feedback

    /// Selection change feedback
    /// Use cases: picker view, segmented control, continuous selection
    func selection() {
        guard hapticsEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // MARK: - Notification Feedback

    /// Success notification
    /// Use cases: task completed, save successful, goal achieved
    func success() {
        guard hapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    /// Warning notification
    /// Use cases: destructive action, caution needed, confirm before proceed
    func warning() {
        guard hapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    /// Error notification
    /// Use cases: operation failed, validation error, alert
    func error() {
        guard hapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    // MARK: - Contextual Helpers (Fitness App Specific)

    /// Single set completed haptic
    func setCompleted() {
        success()
    }

    /// Exercise completed haptic (all sets done)
    func exerciseCompleted() {
        success()
    }

    /// Workout started haptic
    func workoutStarted() {
        medium()
    }

    /// Workout finished haptic
    func workoutFinished() {
        success()
    }

    /// PR (Personal Record) achieved haptic - celebratory!
    /// Double success for emphasis and celebration
    func prAchieved() {
        guard hapticsEnabled else { return }

        // First success
        success()

        // Second success after short delay for emphasis
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            self.success()
        }
    }

    /// Delete action haptic
    func delete() {
        warning()
    }

    /// Value adjusted haptic with progressive intensity
    /// Adjusts intensity based on magnitude of change
    /// - Parameter magnitude: The amount of change (e.g., weight in kg/lbs)
    func valueAdjusted(magnitude: Double) {
        guard hapticsEnabled else { return }

        // Progressive intensity based on magnitude
        // Small changes = light, medium changes = medium, large changes = heavy
        if magnitude < 5 {
            impact(intensity: 0.5) // Light
        } else if magnitude < 25 {
            impact(intensity: 0.7) // Medium
        } else {
            impact(intensity: 1.0) // Heavy
        }
    }

    /// Template or program selected haptic
    func templateSelected() {
        light()
    }

    /// Item added haptic (exercise, food, etc.)
    func itemAdded() {
        light()
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Add haptic feedback to view on tap
    /// - Parameter type: The type of haptic to trigger
    func hapticFeedback(_ type: HapticType) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                switch type {
                case .light: HapticManager.shared.light()
                case .medium: HapticManager.shared.medium()
                case .heavy: HapticManager.shared.heavy()
                case .success: HapticManager.shared.success()
                case .warning: HapticManager.shared.warning()
                case .error: HapticManager.shared.error()
                case .selection: HapticManager.shared.selection()
                }
            }
        )
    }
}

/// Haptic feedback types for View extension
enum HapticType {
    case light, medium, heavy
    case success, warning, error
    case selection
}
