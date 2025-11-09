//
//  SeedingViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// Monitors PersistenceController seeding progress
/// Extracted from MainTabView for better separation of concerns and testability
@Observable @MainActor
final class SeedingViewModel {
    // MARK: - Dependencies

    private let persistenceController: PersistenceController

    // MARK: - State

    private(set) var isSeeding = false
    private(set) var seedingProgress = ""
    private(set) var currentStep = 0
    private(set) var totalSteps = 4
    private(set) var progressPercentage: Double = 0.0

    // MARK: - Computed Properties

    /// Whether to show estimated time remaining
    var shouldShowEstimate: Bool {
        currentStep > 0 && currentStep < totalSteps
    }

    /// Estimated seconds remaining (5 seconds per step)
    var estimatedSeconds: Int {
        (totalSteps - currentStep) * 5
    }

    // MARK: - Init

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        // Check initial seeding state to handle race condition
        self.isSeeding = persistenceController.isSeeding
    }

    // MARK: - Methods

    /// Start monitoring seeding progress
    /// Polls PersistenceController every 100ms until seeding completes
    /// Swift 6.2 Optimization: 100ms polling interval (50% less CPU than 50ms)
    func startMonitoring() async {
        while persistenceController.isSeeding {
            isSeeding = true
            seedingProgress = persistenceController.seedingProgress
            currentStep = persistenceController.currentStep
            totalSteps = persistenceController.totalSteps
            progressPercentage = persistenceController.progressPercentage

            try? await Task.sleep(for: .milliseconds(100))
        }

        // Seeding complete
        isSeeding = false
    }
}
