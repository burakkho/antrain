//
//  NutritionGoalsOnboardingWizard.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Onboarding wizard for first-time nutrition goals setup
struct NutritionGoalsOnboardingWizard: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyNutritionViewModel
    let onComplete: (_ tdee: Double, _ recommendedCalories: Double, _ macros: (Double, Double, Double)) -> Void

    @State private var currentStep = 0
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var height: Double = 170.0
    @State private var weight: Double = 70.0
    @State private var gender: UserProfile.Gender = .male
    @State private var activityLevel: UserProfile.ActivityLevel = .moderatelyActive
    @State private var selectedGoal: TDEECalculator.GoalType = .maintain
    @State private var isSaving = false

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressBar

                // Content
                TabView(selection: $currentStep) {
                    step1_DateOfBirth.tag(0)
                    step2_Height.tag(1)
                    step3_Weight.tag(2)
                    step4_Gender.tag(3)
                    step5_ActivityAndGoal.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("Personalize Your Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? DSColors.primary : DSColors.separator)
                        .frame(height: 4)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))

            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding()
    }

    // MARK: - Steps

    private var step1_DateOfBirth: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("How old are you?")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("We'll use this to calculate your daily calorie needs")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            DatePicker(
                "Date of Birth",
                selection: $dateOfBirth,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()

            if let age = calculateAge(from: dateOfBirth) {
                Text("\(age) years old")
                    .font(DSTypography.body)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.primary)
            }

            Spacer()
        }
    }

    private var step2_Height: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "ruler")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("What's your height?")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("This helps calculate your basal metabolic rate")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            VStack(spacing: 12) {
                Text("\(Int(height)) cm")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(DSColors.primary)

                Slider(value: $height, in: 100...250, step: 1)
                    .tint(DSColors.primary)
                    .padding(.horizontal, 40)

                Text("\(height.formattedHeight(unit: "Kilograms"))")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .padding()

            Spacer()
        }
    }

    private var step3_Weight: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "scalemass")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("What's your current weight?")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("We'll track your progress from here")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            VStack(spacing: 12) {
                Text("\(String(format: "%.1f", weight)) kg")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(DSColors.primary)

                Slider(value: $weight, in: 30...200, step: 0.5)
                    .tint(DSColors.primary)
                    .padding(.horizontal, 40)

                Text("\(weight.formattedWeight(unit: "Kilograms"))")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .padding()

            Spacer()
        }
    }

    private var step4_Gender: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("Select your gender")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("This affects your calorie calculation formula")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            VStack(spacing: 12) {
                ForEach(UserProfile.Gender.allCases, id: \.self) { genderOption in
                    Button {
                        gender = genderOption
                    } label: {
                        HStack {
                            Text(genderOption.rawValue)
                                .font(DSTypography.body)
                                .foregroundStyle(gender == genderOption ? .white : DSColors.textPrimary)

                            Spacer()

                            if gender == genderOption {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding()
                        .background(gender == genderOption ? DSColors.primary : DSColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private var step5_ActivityAndGoal: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("Activity & Goal")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("Almost done! Tell us about your activity level and goal")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Level")
                            .font(DSTypography.body)
                            .fontWeight(.bold)

                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                            Button {
                                activityLevel = level
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(level.rawValue)
                                            .font(DSTypography.body)
                                            .foregroundStyle(activityLevel == level ? .white : DSColors.textPrimary)

                                        Spacer()

                                        if activityLevel == level {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    if let tdeeLevel = TDEECalculator.ActivityLevel(rawValue: level.rawValue) {
                                        Text(tdeeLevel.description)
                                            .font(DSTypography.caption)
                                            .foregroundStyle(activityLevel == level ? .white.opacity(0.8) : DSColors.textSecondary)
                                    }
                                }
                                .padding()
                                .background(activityLevel == level ? DSColors.primary : DSColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Goal")
                            .font(DSTypography.body)
                            .fontWeight(.bold)

                        ForEach(TDEECalculator.GoalType.allCases) { goal in
                            Button {
                                selectedGoal = goal
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(goal.rawValue)
                                            .font(DSTypography.body)
                                            .foregroundStyle(selectedGoal == goal ? .white : DSColors.textPrimary)

                                        Spacer()

                                        if selectedGoal == goal {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    Text(goal.description)
                                        .font(DSTypography.caption)
                                        .foregroundStyle(selectedGoal == goal ? .white.opacity(0.8) : DSColors.textSecondary)
                                }
                                .padding()
                                .background(selectedGoal == goal ? DSColors.primary : DSColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DSColors.cardBackground)
                    .foregroundStyle(DSColors.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    Task {
                        await completeOnboarding()
                    }
                }
            } label: {
                HStack {
                    Text(currentStep < totalSteps - 1 ? "Next" : "Finish")
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "chevron.right")
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(DSColors.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isSaving)
        }
        .padding()
    }

    // MARK: - Helper Methods

    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }

    private func completeOnboarding() async {
        isSaving = true

        // Calculate TDEE
        guard let age = calculateAge(from: dateOfBirth) else { return }

        let tdeeActivityLevel = TDEECalculator.ActivityLevel(rawValue: activityLevel.rawValue) ?? .moderatelyActive

        let tdee = TDEECalculator.calculateTDEE(
            weight: weight,
            height: height,
            age: age,
            gender: gender,
            activityLevel: tdeeActivityLevel
        )

        let recommendedCalories = TDEECalculator.recommendedCalories(tdee: tdee, goal: selectedGoal)
        let recommendedMacros = TDEECalculator.recommendedMacros(calories: recommendedCalories, weight: weight, goal: selectedGoal)

        // Save to profile
        do {
            // Update profile with all info
            if let profile = viewModel.userProfile {
                profile.update(
                    height: height,
                    gender: gender,
                    dateOfBirth: dateOfBirth,
                    activityLevel: activityLevel
                )
            }

            // Add weight entry
            try await viewModel.userProfileRepository.addBodyweightEntry(
                weight: weight,
                date: Date(),
                notes: "Initial weight from onboarding"
            )

            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "hasCompletedNutritionOnboarding")

            // Call completion handler
            onComplete(tdee, recommendedCalories, recommendedMacros)

            dismiss()
        } catch {
            print("Failed to save onboarding data: \(error)")
            isSaving = false
        }
    }
}
