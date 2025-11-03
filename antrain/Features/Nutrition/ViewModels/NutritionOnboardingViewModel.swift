//
//  NutritionOnboardingViewModel.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import Foundation
import Observation

/// Manages nutrition onboarding wizard business logic
@Observable @MainActor
final class NutritionOnboardingViewModel {
    // MARK: - Dependencies
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State
    var currentStep = 0
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    var height: Double = 170.0
    var weight: Double = 70.0
    var gender: UserProfile.Gender = .male
    var activityLevel: UserProfile.ActivityLevel = .moderatelyActive
    var selectedGoal: TDEECalculator.GoalType = .maintain
    var isSaving = false
    var errorMessage: String?

    let totalSteps = 5

    // MARK: - Computed Properties

    var age: Int? {
        calculateAge(from: dateOfBirth)
    }

    // MARK: - Initialization

    init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Actions

    /// Move to next step
    func nextStep() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    /// Move to previous step
    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    /// Calculate age from date of birth
    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }

    /// Complete onboarding and save all data
    func completeOnboarding() async throws -> (
        tdee: Double,
        recommendedCalories: Double,
        macros: (protein: Double, carbs: Double, fats: Double)
    ) {
        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        // Validate required data
        guard let age = calculateAge(from: dateOfBirth) else {
            errorMessage = "Invalid date of birth"
            throw NSError(domain: "NutritionOnboarding", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date of birth"])
        }

        do {
            // Fetch or create profile
            let profile = try await userProfileRepository.fetchOrCreateProfile()

            // Update profile with all info
            profile.update(
                height: height,
                gender: gender,
                dateOfBirth: dateOfBirth,
                activityLevel: activityLevel
            )

            // Add weight entry
            try await userProfileRepository.addBodyweightEntry(
                weight: weight,
                date: Date(),
                notes: "Initial weight from onboarding"
            )

            // Calculate TDEE and recommendations
            let tdeeActivityLevel = TDEECalculator.ActivityLevel(
                rawValue: activityLevel.rawValue
            ) ?? .moderatelyActive

            let tdee = TDEECalculator.calculateTDEE(
                weight: weight,
                height: height,
                age: age,
                gender: gender,
                activityLevel: tdeeActivityLevel
            )

            let recommendedCalories = TDEECalculator.recommendedCalories(
                tdee: tdee,
                goal: selectedGoal
            )

            let recommendedMacros = TDEECalculator.recommendedMacros(
                calories: recommendedCalories,
                weight: weight,
                goal: selectedGoal
            )

            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "hasCompletedNutritionOnboarding")

            return (tdee, recommendedCalories, recommendedMacros)
        } catch {
            errorMessage = "Failed to save onboarding data: \(error.localizedDescription)"
            throw error
        }
    }
}
