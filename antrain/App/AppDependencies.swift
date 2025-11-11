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
///
/// ✅ Singleton pattern for app-wide shared instance
/// Prevents creating multiple repository instances
final class AppDependencies: ObservableObject {

    // MARK: - Singleton

    /// Shared instance for the main app
    /// Initialized lazily on first access
    @MainActor
    static let shared: AppDependencies = {
        AppDependencies(modelContainer: PersistenceController.shared.modelContainer)
    }()
    // MARK: - Repositories
    let workoutRepository: WorkoutRepositoryProtocol
    let exerciseRepository: ExerciseRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let userProfileRepository: UserProfileRepositoryProtocol
    let personalRecordRepository: PersonalRecordRepositoryProtocol
    let workoutTemplateRepository: WorkoutTemplateRepositoryProtocol
    let trainingProgramRepository: TrainingProgramRepositoryProtocol
    let chatRepository: ChatRepositoryProtocol

    // MARK: - Libraries
    let exerciseLibrary: ExerciseLibraryProtocol

    // MARK: - Services
    let prDetectionService: PRDetectionService
    let progressiveOverloadService: ProgressiveOverloadService
    let widgetUpdateService: WidgetUpdateService
    let geminiAPIService: GeminiAPIServiceProtocol
    let workoutContextBuilder: WorkoutContextBuilder

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
        self.chatRepository = ChatRepository(modelContainer: modelContainer)

        // Initialize libraries (stateless)
        self.exerciseLibrary = ExerciseLibrary()

        // Initialize services
        self.prDetectionService = PRDetectionService(
            prRepository: personalRecordRepository
        )
        self.progressiveOverloadService = ProgressiveOverloadService(
            workoutRepository: workoutRepository
        )
        self.widgetUpdateService = WidgetUpdateService(
            workoutRepository: workoutRepository,
            userProfileRepository: userProfileRepository
        )

        // AI Coach services
        self.geminiAPIService = GeminiAPIService()
        self.workoutContextBuilder = WorkoutContextBuilder(
            workoutRepository: workoutRepository,
            personalRecordRepository: personalRecordRepository,
            userProfileRepository: userProfileRepository,
            nutritionRepository: nutritionRepository
        )
    }

    // MARK: - Preview Support
    /// In-memory dependencies for SwiftUI previews
    static var preview: AppDependencies {
        let container = PersistenceController.preview
        return AppDependencies(modelContainer: container)
    }
}
