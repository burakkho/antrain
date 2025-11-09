//
//  AppCoordinator.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI
import Combine

/// Coordinates app-wide navigation and deep linking
/// Replaces NotificationCenter-based navigation with modern state-driven approach
/// Extracted from MainTabView for better separation of concerns
@Observable @MainActor
final class AppCoordinator {
    // MARK: - Navigation State

    /// Deep link destinations within the app
    enum Destination {
        case nutrition
        case workoutsCalendar
        case startWorkout
    }

    /// Currently selected tab (0: Home, 1: Workouts, 2: Nutrition, 3: Profile)
    var selectedTab = 0

    /// Pending destination from deep link (processed after view appears)
    var pendingDestination: Destination?

    // MARK: - Dependencies

    private let workoutManager: ActiveWorkoutManager

    // Swift 6: nonisolated(unsafe) allows deinit to access this property
    // Safe because deinit is only called when no other references exist
    nonisolated(unsafe) private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(workoutManager: ActiveWorkoutManager) {
        self.workoutManager = workoutManager
        setupNotificationObservers()
    }

    // MARK: - Deep Link Handling

    /// Handle navigation to a specific destination
    /// - Parameter destination: Target location in the app
    func handle(destination: Destination) {
        switch destination {
        case .nutrition:
            selectedTab = 2

        case .workoutsCalendar:
            selectedTab = 1

        case .startWorkout:
            handleStartWorkout()
        }
    }

    // MARK: - Widget Actions

    /// Handle "Start Workout" action from widget
    /// Switches to home tab and either resumes existing workout or shows quick actions
    private func handleStartWorkout() {
        selectedTab = 0  // Home tab

        if workoutManager.isActive {
            // Resume existing workout
            withAnimation(.spring(response: 0.3)) {
                workoutManager.showFullScreen = true
            }
        }
        // If no active workout, user can tap "Start Workout" button on home
    }

    // MARK: - Notification Observers

    /// Setup NotificationCenter observers for legacy deep linking
    /// TODO: Migrate to URL schemes (.onOpenURL) for better testability
    @MainActor
    private func setupNotificationObservers() {
        // Nutrition tab navigation
        NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNutritionTab"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handle(destination: .nutrition)
                }
            }
            .store(in: &cancellables)

        // Workouts calendar navigation
        NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToWorkoutsCalendar"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handle(destination: .workoutsCalendar)
                }
            }
            .store(in: &cancellables)

        // Widget "Start Workout" action
        NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToWorkout"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handle(destination: .startWorkout)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Cleanup

    deinit {
        cancellables.removeAll()
    }
}
