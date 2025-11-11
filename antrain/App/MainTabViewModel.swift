//
//  MainTabViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI
import Observation

/// Manages MainTabView lifecycle and coordinates services
/// Extracted from MainTabView for better separation of concerns and testability
@Observable @MainActor
final class MainTabViewModel {
    // MARK: - Dependencies

    private let appDependencies: AppDependencies
    private let workoutManager: ActiveWorkoutManager
    private let coordinator: AppCoordinator

    // MARK: - State

    private(set) var hasInitialized = false

    // MARK: - Init

    init(
        appDependencies: AppDependencies,
        workoutManager: ActiveWorkoutManager,
        coordinator: AppCoordinator
    ) {
        self.appDependencies = appDependencies
        self.workoutManager = workoutManager
        self.coordinator = coordinator
    }

    // MARK: - Lifecycle

    /// Called when MainTabView appears
    /// Performs one-time initialization: workout restore only
    /// ✅ OPTIMIZED: Widget update removed from startup (Apple best practice)
    /// Widget will be updated after workout completion or on app become active
    func onAppear() async {
        guard !hasInitialized else { return }
        hasInitialized = true

        // Restore workout session (if exists)
        await restoreWorkoutSession()

        // ✅ Widget update moved to background trigger
        // See updateWidgetIfNeeded() - called after workout completion
    }

    // MARK: - Workout Restoration

    /// Silently restore active workout session if exists
    /// Allows users to continue workouts after app restart
    private func restoreWorkoutSession() async {
        let restored = await workoutManager.restoreState(
            workoutRepository: appDependencies.workoutRepository,
            exerciseRepository: appDependencies.exerciseRepository,
            prDetectionService: appDependencies.prDetectionService,
            progressiveOverloadService: appDependencies.progressiveOverloadService,
            userProfileRepository: appDependencies.userProfileRepository,
            widgetUpdateService: appDependencies.widgetUpdateService
        )

        if restored {
            print("✅ Workout session restored successfully")
        }
    }

    // MARK: - Widget Update
    // ✅ REMOVED: Widget update logic moved to WidgetUpdateService
    // Widget is now updated after workout completion via widgetUpdateService.updateWidgetData()
    // See: WidgetUpdateService.swift (optimized with fetchByDateRange)
}
