//
//  AppDependencies.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

/// Central dependency injection container
/// Manages all repositories and libraries for the app
final class AppDependencies: ObservableObject {
    // MARK: - Repositories
    let workoutRepository: WorkoutRepositoryProtocol
    let exerciseRepository: ExerciseRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let userProfileRepository: UserProfileRepositoryProtocol
    let personalRecordRepository: PersonalRecordRepositoryProtocol
    let workoutTemplateRepository: WorkoutTemplateRepositoryProtocol
    let trainingProgramRepository: TrainingProgramRepositoryProtocol

    // MARK: - Libraries
    let exerciseLibrary: ExerciseLibraryProtocol

    // MARK: - Services
    let prDetectionService: PRDetectionService
    let progressiveOverloadService: ProgressiveOverloadService
    let liveActivityManager: LiveActivityManager
    let widgetUpdateService: WidgetUpdateService

    // MARK: - Initialization
    init(modelContainer: ModelContainer) {
        // Initialize repositories with ModelContainer
        // @ModelActor will create its own ModelContext
        self.workoutRepository = WorkoutRepository(modelContainer: modelContainer)
        self.exerciseRepository = ExerciseRepository(modelContainer: modelContainer)
        self.nutritionRepository = NutritionRepository(modelContainer: modelContainer)
        self.userProfileRepository = UserProfileRepository(modelContainer: modelContainer)
        self.personalRecordRepository = PersonalRecordRepository(modelContainer: modelContainer)
        self.workoutTemplateRepository = WorkoutTemplateRepository(modelContainer: modelContainer)
        self.trainingProgramRepository = TrainingProgramRepository(modelContainer: modelContainer)

        // Initialize libraries (stateless)
        self.exerciseLibrary = ExerciseLibrary()

        // Initialize services
        self.prDetectionService = PRDetectionService(
            prRepository: personalRecordRepository
        )
        self.progressiveOverloadService = ProgressiveOverloadService(
            workoutRepository: workoutRepository
        )
        self.liveActivityManager = LiveActivityManager()
        self.widgetUpdateService = WidgetUpdateService(
            workoutRepository: workoutRepository,
            userProfileRepository: userProfileRepository
        )
    }

    // MARK: - Preview Support
    /// In-memory dependencies for SwiftUI previews
    static var preview: AppDependencies {
        let container = PersistenceController.preview
        return AppDependencies(modelContainer: container)
    }
}
