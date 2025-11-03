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
    let userProfileRepository: UserProfileRepositoryProtocol
    let onComplete: (_ tdee: Double, _ recommendedCalories: Double, _ macros: (Double, Double, Double)) -> Void

    @State private var viewModel: NutritionOnboardingViewModel?

    var body: some View {
        if let vm = viewModel {
            wizardContent(viewModel: vm)
        } else {
            DSLoadingView()
                .onAppear {
                    if viewModel == nil {
                        viewModel = NutritionOnboardingViewModel(
                            userProfileRepository: userProfileRepository
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private func wizardContent(viewModel vm: NutritionOnboardingViewModel) -> some View {
        @Bindable var viewModel = vm
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressBar(viewModel: viewModel)

                // Content
                TabView(selection: $viewModel.currentStep) {
                    step1_DateOfBirth(viewModel: viewModel).tag(0)
                    step2_Height(viewModel: viewModel).tag(1)
                    step3_Weight(viewModel: viewModel).tag(2)
                    step4_Gender(viewModel: viewModel).tag(3)
                    step5_ActivityAndGoal(viewModel: viewModel).tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)

                // Navigation buttons
                navigationButtons(viewModel: viewModel)
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

    @ViewBuilder
    private func progressBar(viewModel: NutritionOnboardingViewModel) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= viewModel.currentStep ? DSColors.primary : DSColors.separator)
                        .frame(height: 4)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))

            Text("Step \(viewModel.currentStep + 1) of \(viewModel.totalSteps)")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding()
    }

    // MARK: - Steps

    @ViewBuilder
    private func step1_DateOfBirth(viewModel vm: NutritionOnboardingViewModel) -> some View {
        @Bindable var viewModel = vm
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
                selection: $viewModel.dateOfBirth,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()

            if let age = viewModel.age {
                Text("\(age) years old")
                    .font(DSTypography.body)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.primary)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func step2_Height(viewModel vm: NutritionOnboardingViewModel) -> some View {
        @Bindable var viewModel = vm
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
                Text("\(Int(viewModel.height)) cm")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(DSColors.primary)

                Slider(value: $viewModel.height, in: 100...250, step: 1)
                    .tint(DSColors.primary)
                    .padding(.horizontal, 40)

                Text("\(viewModel.height.formattedHeight(unit: "Kilograms"))")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .padding()

            Spacer()
        }
    }

    @ViewBuilder
    private func step3_Weight(viewModel vm: NutritionOnboardingViewModel) -> some View {
        @Bindable var viewModel = vm
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
                Text("\(String(format: "%.1f", viewModel.weight)) kg")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(DSColors.primary)

                Slider(value: $viewModel.weight, in: 30...200, step: 0.5)
                    .tint(DSColors.primary)
                    .padding(.horizontal, 40)

                Text("\(viewModel.weight.formattedWeight(unit: "Kilograms"))")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
            .padding()

            Spacer()
        }
    }

    @ViewBuilder
    private func step4_Gender(viewModel vm: NutritionOnboardingViewModel) -> some View {
        @Bindable var viewModel = vm
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
                        viewModel.gender = genderOption
                    } label: {
                        HStack {
                            Text(genderOption.rawValue)
                                .font(DSTypography.body)
                                .foregroundStyle(viewModel.gender == genderOption ? .white : DSColors.textPrimary)

                            Spacer()

                            if viewModel.gender == genderOption {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding()
                        .background(viewModel.gender == genderOption ? DSColors.primary : DSColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    @ViewBuilder
    private func step5_ActivityAndGoal(viewModel vm: NutritionOnboardingViewModel) -> some View {
        @Bindable var viewModel = vm
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
                                viewModel.activityLevel = level
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(level.rawValue)
                                            .font(DSTypography.body)
                                            .foregroundStyle(viewModel.activityLevel == level ? .white : DSColors.textPrimary)

                                        Spacer()

                                        if viewModel.activityLevel == level {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    if let tdeeLevel = TDEECalculator.ActivityLevel(rawValue: level.rawValue) {
                                        Text(tdeeLevel.description)
                                            .font(DSTypography.caption)
                                            .foregroundStyle(viewModel.activityLevel == level ? .white.opacity(0.8) : DSColors.textSecondary)
                                    }
                                }
                                .padding()
                                .background(viewModel.activityLevel == level ? DSColors.primary : DSColors.cardBackground)
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
                                viewModel.selectedGoal = goal
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(goal.rawValue)
                                            .font(DSTypography.body)
                                            .foregroundStyle(viewModel.selectedGoal == goal ? .white : DSColors.textPrimary)

                                        Spacer()

                                        if viewModel.selectedGoal == goal {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    Text(goal.description)
                                        .font(DSTypography.caption)
                                        .foregroundStyle(viewModel.selectedGoal == goal ? .white.opacity(0.8) : DSColors.textSecondary)
                                }
                                .padding()
                                .background(viewModel.selectedGoal == goal ? DSColors.primary : DSColors.cardBackground)
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

    @ViewBuilder
    private func navigationButtons(viewModel: NutritionOnboardingViewModel) -> some View {
        HStack(spacing: 16) {
            if viewModel.currentStep > 0 {
                Button {
                    withAnimation {
                        viewModel.previousStep()
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
                if viewModel.currentStep < viewModel.totalSteps - 1 {
                    withAnimation {
                        viewModel.nextStep()
                    }
                } else {
                    Task {
                        await completeOnboarding(viewModel: viewModel)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.currentStep < viewModel.totalSteps - 1 ? "Next" : "Finish")
                    if viewModel.currentStep < viewModel.totalSteps - 1 {
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
            .disabled(viewModel.isSaving)
        }
        .padding()
    }

    // MARK: - Helper Methods

    private func completeOnboarding(viewModel: NutritionOnboardingViewModel) async {
        do {
            let result = try await viewModel.completeOnboarding()

            // Call completion handler
            onComplete(result.tdee, result.recommendedCalories, result.macros)

            dismiss()
        } catch {
            // Error is already handled in ViewModel
            print("Failed to save onboarding data: \(error)")
        }
    }
}
