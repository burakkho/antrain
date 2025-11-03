import Foundation
import Observation
import SwiftUI

/// Lifting session view model
/// Manages workout state, exercises, sets, and save logic
@Observable @MainActor
final class LiftingSessionViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let exerciseRepository: ExerciseRepositoryProtocol
    private let prDetectionService: PRDetectionService

    // MARK: - State

    var workout: Workout
    var exercises: [WorkoutExercise] = []
    var isLoading = false
    var errorMessage: String?
    var showExerciseSelection = false
    var showSummary = false

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol,
        prDetectionService: PRDetectionService
    ) {
        self.workoutRepository = workoutRepository
        self.exerciseRepository = exerciseRepository
        self.prDetectionService = prDetectionService
        self.workout = Workout(date: Date(), type: .lifting)
    }

    // MARK: - Template Integration

    /// Load workout from template
    /// Converts template exercises to workout exercises with pre-populated sets
    func loadFromTemplate(_ template: WorkoutTemplate, templateRepository: WorkoutTemplateRepositoryProtocol) async {
        isLoading = true
        errorMessage = nil

        do {
            // Clear existing exercises
            exercises.removeAll()
            workout.exercises = []

            // Convert each template exercise to workout exercise
            for templateExercise in template.exercises.sorted() {
                // Fetch the actual exercise from repository
                guard let exercise = try await exerciseRepository.fetchExercise(by: templateExercise.exerciseId) else {
                    print("⚠️ Exercise not found: \(templateExercise.exerciseName)")
                    continue
                }

                // Create workout exercise
                let workoutExercise = WorkoutExercise(
                    exercise: exercise,
                    orderIndex: templateExercise.order
                )

                // Pre-populate sets based on template configuration
                for _ in 0..<templateExercise.setCount {
                    let set = WorkoutSet(
                        reps: templateExercise.repRangeMin, // Start with min reps
                        weight: 0, // User will fill in weight
                        isCompleted: false
                    )
                    workoutExercise.sets.append(set)
                }

                // Add notes if available
                if let notes = templateExercise.notes {
                    workoutExercise.notes = notes
                }

                exercises.append(workoutExercise)
            }

            workout.exercises = exercises

            // Mark template as used
            try await templateRepository.markTemplateUsed(template)

            print("✅ Loaded \(exercises.count) exercises from template: \(template.name)")
        } catch {
            errorMessage = "Failed to load template: \(error.localizedDescription)"
            print("❌ Template load error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Exercise Management

    /// Add exercise to workout
    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            orderIndex: exercises.count
        )
        exercises.append(workoutExercise)
        workout.exercises = exercises
    }

    /// Remove exercise from workout
    func removeExercise(_ workoutExercise: WorkoutExercise) {
        exercises.removeAll { $0.id == workoutExercise.id }
        workout.exercises = exercises
        reorderExercises()
    }

    /// Reorder exercises
    func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        reorderExercises()
    }

    private func reorderExercises() {
        for (index, exercise) in exercises.enumerated() {
            exercise.orderIndex = index
        }
        workout.exercises = exercises
    }

    // MARK: - Set Management

    /// Add set to exercise (auto-fill from last set)
    func addSet(to workoutExercise: WorkoutExercise) {
        let newSet: WorkoutSet

        if let lastSet = workoutExercise.sets.last {
            // Auto-fill from last set
            newSet = WorkoutSet(
                reps: lastSet.reps,
                weight: lastSet.weight,
                isCompleted: false
            )
        } else {
            // First set - default values
            newSet = WorkoutSet(
                reps: 10,
                weight: 0,
                isCompleted: false
            )
        }

        workoutExercise.sets.append(newSet)
    }

    /// Mark set as completed
    func completeSet(_ set: WorkoutSet) {
        set.isCompleted = true
    }

    /// Update set values
    func updateSet(_ set: WorkoutSet, reps: Int, weight: Double) {
        set.reps = reps
        set.weight = weight
    }

    /// Remove set from exercise
    func removeSet(_ set: WorkoutSet, from workoutExercise: WorkoutExercise) {
        workoutExercise.sets.removeAll { $0.id == set.id }
    }

    // MARK: - Save & Cancel

    /// Save workout
    /// Creates a fresh workout with all exercises and sets to ensure proper SwiftData persistence
    func saveWorkout(notes: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            // Create a FRESH workout (fixes transient object issue)
            let newWorkout = Workout(
                date: workout.date,
                type: .lifting,
                duration: Date().timeIntervalSince(workout.date),
                notes: notes
            )

            // Rebuild exercise hierarchy properly
            for existingExercise in exercises {
                // Skip if exercise is nil (shouldn't happen, but safety check)
                guard let exercise = existingExercise.exercise else { continue }

                let newWorkoutExercise = WorkoutExercise(
                    exercise: exercise,
                    orderIndex: existingExercise.orderIndex
                )

                // Add all sets
                for existingSet in existingExercise.sets {
                    let newSet = WorkoutSet(
                        reps: existingSet.reps,
                        weight: existingSet.weight,
                        isCompleted: existingSet.isCompleted
                    )
                    newWorkoutExercise.sets.append(newSet)
                }

                // Use model's relationship method for proper SwiftData tracking
                newWorkout.addExercise(newWorkoutExercise)
            }

            // Validate and save
            try newWorkout.validate()
            try await workoutRepository.save(newWorkout)

            // Detect and save new PRs
            let newPRs = try await prDetectionService.detectAndSavePRs(from: newWorkout)
            if !newPRs.isEmpty {
                print("🏆 New PRs detected: \(newPRs.count)")
                for pr in newPRs {
                    print("  - \(pr.exerciseName): \(pr.estimated1RM)kg")
                }
            }

            // Success - notify views to refresh
            NotificationCenter.default.post(name: NSNotification.Name("WorkoutSaved"), object: nil)
        } catch {
            errorMessage = "Failed to save workout: \(error.localizedDescription)"
            print("❌ Workout save error: \(error)")
        }

        isLoading = false
    }

    /// Check if workout can be saved
    var canSave: Bool {
        !exercises.isEmpty && exercises.contains { !$0.sets.isEmpty }
    }

    /// Check if workout has data (for cancel confirmation)
    var hasData: Bool {
        !exercises.isEmpty
    }
}
