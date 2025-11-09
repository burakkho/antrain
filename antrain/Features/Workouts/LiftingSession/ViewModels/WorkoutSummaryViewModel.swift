//
//  WorkoutSummaryViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// ViewModel for WorkoutSummaryView
/// Handles data loading, PR detection, comparison, and save/delete operations
@Observable @MainActor
final class WorkoutSummaryViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let prRepository: PersonalRecordRepositoryProtocol
    private let prDetectionService: PRDetectionService

    // MARK: - Input Data

    let workout: Workout
    let exercises: [WorkoutExercise]

    // Cached duration (calculated once on init)
    private let cachedDuration: TimeInterval

    // MARK: - State

    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    // PR Detection
    var detectedPRs: [PersonalRecord] = []
    var isLoadingPRs = false

    // Previous Workout Comparison
    var previousWorkout: Workout?
    var workoutComparison: WorkoutComparison?
    var isLoadingComparison = false

    // Muscle Group Stats
    var muscleGroupStats: [MuscleGroupStats] = []

    // User Input
    var notes: String = ""
    var rating: Int? = nil // 1-5 stars

    // MARK: - Initialization

    init(
        workout: Workout,
        exercises: [WorkoutExercise],
        workoutRepository: WorkoutRepositoryProtocol,
        prRepository: PersonalRecordRepositoryProtocol,
        prDetectionService: PRDetectionService
    ) {
        self.workout = workout
        self.exercises = exercises
        self.workoutRepository = workoutRepository
        self.prRepository = prRepository
        self.prDetectionService = prDetectionService

        // Calculate duration once on init (performance optimization)
        if workout.duration > 0 {
            // Saved workout - use stored duration
            self.cachedDuration = workout.duration
        } else {
            // Active workout - calculate duration from start time
            self.cachedDuration = Date().timeIntervalSince(workout.date)
        }
    }

    // MARK: - Data Loading

    /// Load all data (PRs, comparison, stats)
    func loadData() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Void.self) { group in
            // Load PRs in parallel
            group.addTask {
                await self.loadPRs()
            }

            // Load previous workout comparison
            group.addTask {
                await self.loadPreviousWorkoutComparison()
            }

            // Calculate muscle group stats
            group.addTask {
                await self.calculateMuscleGroupStats()
            }
        }

        isLoading = false
    }

    /// Detect and load PRs for this workout
    private func loadPRs() async {
        isLoadingPRs = true

        do {
            // Detect PRs from the workout
            let prs = try await prDetectionService.detectAndSavePRs(from: workout)
            detectedPRs = prs
        } catch {
            print("Failed to detect PRs: \(error)")
            errorMessage = "Failed to detect PRs"
        }

        isLoadingPRs = false
    }

    /// Load and compare with previous similar workout
    private func loadPreviousWorkoutComparison() async {
        isLoadingComparison = true

        do {
            // Fetch all workouts of same type
            let allWorkouts = try await workoutRepository.fetchByType(workout.type)

            // Find most recent workout before this one
            let previous = allWorkouts
                .filter { $0.date < workout.date && $0.id != workout.id }
                .sorted { $0.date > $1.date }
                .first

            if let previous {
                previousWorkout = previous
                workoutComparison = workout.compare(with: previous)
            }
        } catch {
            print("Failed to load previous workout: \(error)")
            // Not critical, just skip comparison
        }

        isLoadingComparison = false
    }

    /// Calculate muscle group statistics
    private func calculateMuscleGroupStats() async {
        muscleGroupStats = workout.muscleGroupStats
    }

    // MARK: - Actions

    /// Save workout with notes and rating
    func saveWorkout() async {
        isSaving = true
        errorMessage = nil

        do {
            // Update workout with notes
            if !notes.isEmpty {
                workout.notes = notes
            }

            // Save rating to workout model
            if let rating {
                workout.rating = rating
            }

            // Save workout to repository
            try await workoutRepository.save(workout)

            // PRs are already saved by prDetectionService during loadPRs()
        } catch {
            errorMessage = "Failed to save workout: \(error.localizedDescription)"
            print("Save error: \(error)")
        }

        isSaving = false
    }

    /// Delete this workout
    func deleteWorkout() async throws {
        try await workoutRepository.delete(workout)
    }

    // MARK: - Computed Properties

    /// Total volume for display
    var totalVolume: Double {
        workout.totalVolume
    }

    /// Total tonnage (alias for volume)
    var totalTonnage: Double {
        workout.totalTonnage
    }

    /// Total number of sets
    var totalSets: Int {
        workout.totalSets
    }

    /// Total number of exercises
    var exerciseCount: Int {
        exercises.count
    }

    /// Workout duration
    /// Cached on initialization for performance (no repeated Date() calls)
    var duration: TimeInterval {
        cachedDuration
    }

    /// Formatted duration string
    var durationDisplay: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            // 1+ hours: show "1h 25m"
            return "\(hours)h \(minutes)m"
        } else if seconds > 0 {
            // < 1 hour with seconds: show "25m 30s"
            return "\(minutes)m \(seconds)s"
        } else {
            // Exactly minutes: show "25 min"
            return "\(minutes) min"
        }
    }

    /// Top 3 muscle groups trained
    var topMuscleGroups: [MuscleGroup] {
        workout.topMuscleGroups
    }

    /// Whether there are new PRs
    var hasNewPRs: Bool {
        !detectedPRs.isEmpty
    }

    /// PR count
    var prCount: Int {
        detectedPRs.count
    }

    /// Whether there's a previous workout to compare with
    var hasPreviousWorkout: Bool {
        previousWorkout != nil
    }

    /// Volume change from previous workout (if available)
    var volumeChange: Double? {
        workoutComparison?.volumeChange
    }

    /// Volume change percentage
    var volumeChangePercentage: Double? {
        workoutComparison?.volumeChangePercentage
    }

    /// Whether this workout is an improvement
    var isImprovement: Bool {
        workoutComparison?.isImprovement ?? false
    }
}
