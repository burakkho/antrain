//
//  WidgetUpdateService.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation

/// Service responsible for updating widget data after workouts
/// Separated from ViewModel for Single Responsibility Principle
@MainActor
final class WidgetUpdateService {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.workoutRepository = workoutRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Widget Data Update

    /// Update widget with current week's workout count and active program
    /// Called after saving a workout to refresh home screen widget
    func updateWidgetData() async {
        do {
            // Fetch this week's workouts
            let calendar = Calendar.current
            let now = Date()
            guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
                return
            }

            let allWorkouts = try await workoutRepository.fetchAll()
            let thisWeekWorkouts = allWorkouts.filter { workout in
                workout.date >= startOfWeek && workout.date <= now
            }

            // Update widget data
            WidgetDataHelper.shared.updateWorkoutCount(thisWeekWorkouts.count)
            WidgetDataHelper.shared.updateLastWorkoutDate(now)

            // Get active program name if exists
            let profile = try await userProfileRepository.fetchOrCreateProfile()
            let programName = profile.activeProgram?.name
            WidgetDataHelper.shared.updateActiveProgram(programName)

            print("✅ Widget data updated: \(thisWeekWorkouts.count) workouts this week")
        } catch {
            print("⚠️ Failed to update widget data: \(error)")
        }
    }
}
