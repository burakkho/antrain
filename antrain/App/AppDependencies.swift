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

    // MARK: - Convenience Aliases
    var prRepository: PersonalRecordRepository {
        personalRecordRepository as! PersonalRecordRepository
    }

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
            prRepository: personalRecordRepository as! PersonalRecordRepository
        )
        self.progressiveOverloadService = ProgressiveOverloadService(
            workoutRepository: workoutRepository
        )

        // Training Programs v2.0: Inject program repository into template repository for deletion safety
        Task {
            if let templateRepo = workoutTemplateRepository as? WorkoutTemplateRepository {
                await templateRepo.setTrainingProgramRepository(trainingProgramRepository)
            }
        }
    }

    // MARK: - Preview Support
    /// In-memory dependencies for SwiftUI previews
    static var preview: AppDependencies {
        let container = PersistenceController.preview
        return AppDependencies(modelContainer: container)
    }
}
