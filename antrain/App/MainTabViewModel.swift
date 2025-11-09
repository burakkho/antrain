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
    /// Performs one-time initialization: workout restore + widget update
    func onAppear() async {
        guard !hasInitialized else { return }
        hasInitialized = true

        // Restore workout session (if exists)
        await restoreWorkoutSession()

        // Update widget data
        await updateWidgetData()
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

    /// Update widget with current week's workout stats
    /// Called on app launch to keep widget data fresh
    private func updateWidgetData() async {
        do {
            // Fetch this week's workouts
            let calendar = Calendar.current
            let now = Date()
            guard let startOfWeek = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            ) else {
                return
            }

            let workoutRepo = appDependencies.workoutRepository
            let allWorkouts = try await workoutRepo.fetchAll()
            let thisWeekWorkouts = allWorkouts.filter { workout in
                workout.date >= startOfWeek && workout.date <= now
            }

            // Get active program name
            let profile = try await appDependencies.userProfileRepository.fetchOrCreateProfile()
            let programName = profile.activeProgram?.name

            // Update widget
            WidgetDataHelper.shared.updateWidgetData(
                workoutCount: thisWeekWorkouts.count,
                lastWorkoutDate: thisWeekWorkouts.first?.date,
                activeProgram: programName
            )

            print("✅ Widget data updated: \(thisWeekWorkouts.count) workouts this week")
        } catch {
            print("⚠️ Failed to update widget data: \(error)")
        }
    }
}
