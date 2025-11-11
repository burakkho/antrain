//
//  OnboardingViewModel.swift
//  antrain
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Observation

/// ViewModel for onboarding wizard
/// Manages user input state and profile creation
@Observable @MainActor
final class OnboardingViewModel {
    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Navigation State

    var currentStep: Int = 0
    let totalSteps: Int = 6  // 0: Welcome, 1: Basic, 2: Level, 3: Goals, 4: Frequency+Equipment, 5: Completion

    // MARK: - Form State

    // Unit preference
    enum UnitSystem: String, CaseIterable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    var selectedUnitSystem: UnitSystem = .metric

    // Basic Info (Step 1)
    var name: String = ""
    var height: Double = 170.0  // cm (metric) or inches (imperial)
    var weight: Double = 70.0   // kg (metric) or lbs (imperial)
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    var gender: UserProfile.Gender? = nil

    // Fitness Level (Step 2)
    var fitnessLevel: UserProfile.FitnessLevel? = nil

    // Fitness Goals (Step 3)
    var selectedGoals: Set<UserProfile.FitnessGoal> = []

    // Frequency + Equipment (Step 4)
    var weeklyWorkoutFrequency: Int = 3  // Default 3 days/week
    var equipment: UserProfile.Equipment? = .gym  // Default gym

    // MARK: - UI State

    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var age: Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }

    var canProceedFromStep: [Int: Bool] {
        return [
            0: true,  // Welcome - always can proceed
            1: true,  // Basic Info - all optional
            2: fitnessLevel != nil,  // Fitness Level - REQUIRED
            3: !selectedGoals.isEmpty,  // Goals - REQUIRED (min 1)
            4: true,  // Frequency+Equipment - has defaults
            5: true   // Completion - always can proceed
        ]
    }

    var progressPercentage: Double {
        // Skip welcome (0) in progress calculation
        let actualStep = max(0, currentStep - 1)
        let actualTotal = totalSteps - 2  // Exclude welcome and completion
        return Double(actualStep) / Double(actualTotal)
    }

    // MARK: - Initialization

    init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Navigation

    func goToNextStep() {
        guard currentStep < totalSteps - 1 else { return }
        guard canProceedFromStep[currentStep] == true else { return }

        withAnimation(.easeInOut) {
            currentStep += 1
        }
    }

    func goToPreviousStep() {
        guard currentStep > 0 else { return }

        withAnimation(.easeInOut) {
            currentStep -= 1
        }
    }

    func goToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps else { return }

        withAnimation(.easeInOut) {
            currentStep = step
        }
    }

    // MARK: - Actions

    func toggleGoal(_ goal: UserProfile.FitnessGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
    }

    /// Switch between metric and imperial units
    /// Converts height and weight values accordingly
    func switchUnitSystem(to newSystem: UnitSystem) {
        guard newSystem != selectedUnitSystem else { return }

        if newSystem == .imperial {
            // Convert cm → inches, kg → lbs
            height = height / 2.54  // cm to inches
            weight = weight * 2.20462  // kg to lbs
        } else {
            // Convert inches → cm, lbs → kg
            height = height * 2.54  // inches to cm
            weight = weight / 2.20462  // lbs to kg
        }

        selectedUnitSystem = newSystem
    }

    /// Complete onboarding and save profile
    func completeOnboarding() async throws {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch or create profile
            let profile = try await userProfileRepository.fetchOrCreateProfile()

            // Convert height/weight to metric for database (standardize storage)
            let heightInCm = selectedUnitSystem == .metric ? height : height * 2.54
            let weightInKg = selectedUnitSystem == .metric ? weight : weight / 2.20462

            // Update with onboarding data
            profile.update(
                name: name.isEmpty ? nil : name,
                height: heightInCm,
                gender: gender,
                dateOfBirth: dateOfBirth
            )

            // Update fitness info
            profile.fitnessLevel = fitnessLevel
            profile.fitnessGoals = Array(selectedGoals)
            profile.weeklyWorkoutFrequency = weeklyWorkoutFrequency
            profile.availableEquipment = equipment

            // Mark onboarding as completed
            profile.hasCompletedInitialOnboarding = true

            // Save all changes to persistence
            try await userProfileRepository.saveProfile()

            // Safety: Mark nutrition onboarding as completed too
            // This prevents nutrition wizard from appearing after main onboarding
            UserDefaults.standard.set(true, forKey: "hasCompletedNutritionOnboarding")

            isLoading = false
            print("✅ [Onboarding] Profile saved successfully")

        } catch {
            isLoading = false
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            print("❌ [Onboarding] Error saving profile: \(error)")
            throw error
        }
    }

    // MARK: - Validation

    func validateStep(_ step: Int) -> Bool {
        return canProceedFromStep[step] ?? false
    }
}
