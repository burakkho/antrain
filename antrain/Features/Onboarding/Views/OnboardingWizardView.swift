//
//  OnboardingWizardView.swift
//  antrain
//
//  Created by Claude Code
//

import SwiftUI

/// Onboarding wizard for first-time app users
/// Collects essential profile information for AI Coach personalization
struct OnboardingWizardView: View {
    @Environment(\.dismiss) private var dismiss
    let userProfileRepository: UserProfileRepositoryProtocol
    let onComplete: () -> Void

    @State private var viewModel: OnboardingViewModel?
    @FocusState private var focusedField: BasicInfoField?

    var body: some View {
        if let vm = viewModel {
            wizardContent(viewModel: vm)
        } else {
            DSLoadingView()
                .onAppear {
                    if viewModel == nil {
                        viewModel = OnboardingViewModel(
                            userProfileRepository: userProfileRepository
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private func wizardContent(viewModel: OnboardingViewModel) -> some View {
        content(viewModel: viewModel)
    }

    @ViewBuilder
    private func content(viewModel vm: OnboardingViewModel) -> some View {
        @Bindable var viewModel = vm

        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar (only show after welcome screen)
                if viewModel.currentStep > 0 && viewModel.currentStep < viewModel.totalSteps - 1 {
                    progressBar(viewModel: viewModel)
                }

                // Content - Wizard steps
                TabView(selection: $viewModel.currentStep) {
                    step0_Welcome(viewModel: vm).tag(0)
                    step1_BasicInfo(viewModel: vm).tag(1)
                    step2_FitnessLevel(viewModel: vm).tag(2)
                    step3_FitnessGoals(viewModel: vm).tag(3)
                    step4_FrequencyEquipment(viewModel: vm).tag(4)
                    step5_Completion(viewModel: vm).tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)

                // Navigation buttons (hide on welcome and completion)
                if viewModel.currentStep > 0 && viewModel.currentStep < viewModel.totalSteps - 1 {
                    navigationButtons(viewModel: viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Skip button (only on welcome and steps, not completion)
                if viewModel.currentStep < viewModel.totalSteps - 1 {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Skip")) {
                            dismiss()
                        }
                        .font(DSTypography.callout)
                    }
                }
            }
        }
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private func progressBar(viewModel: OnboardingViewModel) -> some View {
        VStack(spacing: 8) {
            // Progress segments
            HStack(spacing: 4) {
                // Skip welcome (step 0) and completion (step 5)
                ForEach(1..<viewModel.totalSteps - 1, id: \.self) { step in
                    Rectangle()
                        .fill(step <= viewModel.currentStep ? DSColors.primary : DSColors.separator)
                        .frame(height: 4)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))

            // Step counter
            Text("Step \(viewModel.currentStep) of \(viewModel.totalSteps - 2)")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding()
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private func navigationButtons(viewModel: OnboardingViewModel) -> some View {
        HStack(spacing: 16) {
            // Back button
            if viewModel.currentStep > 1 {
                DSSecondaryButton(title: "Back") {
                    viewModel.goToPreviousStep()
                }
            }

            // Continue button
            DSPrimaryButton(title: "Continue") {
                viewModel.goToNextStep()
            }
            .disabled(!viewModel.validateStep(viewModel.currentStep))
        }
        .padding()
    }

    // MARK: - Step 0: Welcome

    @ViewBuilder
    private func step0_Welcome(viewModel: OnboardingViewModel) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // App logo/icon
            Image("antrain-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

            VStack(spacing: 12) {
                // Title
                Text("Welcome to Antrain")
                    .font(DSTypography.largeTitle)
                    .foregroundStyle(DSColors.textPrimary)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("Your AI-powered fitness companion")
                    .font(DSTypography.title3)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)

                // Description
                Text("Let's personalize your training experience in just a few steps")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }

            Spacer()

            VStack(spacing: 16) {
                // Primary CTA
                DSPrimaryButton(title: "Get Started") {
                    viewModel.goToNextStep()
                }
                .padding(.horizontal, 40)

                // Skip link
                Button(String(localized: "I'll do this later")) {
                    dismiss()
                }
                .font(DSTypography.callout)
                .foregroundStyle(DSColors.textTertiary)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step 1: Basic Info

    @ViewBuilder
    private func step1_BasicInfo(viewModel vm: OnboardingViewModel) -> some View {
        @Bindable var viewModel = vm

        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 60))
                        .foregroundStyle(DSColors.primary)

                    Text("Tell us about yourself")
                        .font(DSTypography.title2)
                        .fontWeight(.bold)

                    Text("This helps us personalize your experience")
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                VStack(spacing: 20) {
                    // Unit System Toggle
                    VStack(spacing: 12) {
                        Text("Preferred Units")
                            .font(DSTypography.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Picker("Unit System", selection: $viewModel.selectedUnitSystem) {
                            ForEach(OnboardingViewModel.UnitSystem.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.selectedUnitSystem) { _, newValue in
                            viewModel.switchUnitSystem(to: newValue)
                        }
                    }
                    .padding()
                    .background(DSColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Name (optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name (Optional)")
                            .font(DSTypography.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColors.textPrimary)

                        TextField("Enter your name", text: $viewModel.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.done)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .textContentType(.name)
                            .onSubmit {
                                Task { @MainActor in
                                    focusedField = nil
                                }
                            }
                            .font(DSTypography.body)
                            .padding()
                            .background(DSColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Height (optional)
                    VStack(spacing: 12) {
                        Text("Height (Optional)")
                            .font(DSTypography.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Display height based on unit system
                        if viewModel.selectedUnitSystem == .metric {
                            Text("\(Int(viewModel.height)) cm")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(DSColors.primary)

                            Slider(value: $viewModel.height, in: 100...250, step: 1)
                                .tint(DSColors.primary)
                        } else {
                            // Imperial: convert to feet and inches
                            let totalInches = Int(viewModel.height)
                            let feet = totalInches / 12
                            let inches = totalInches % 12

                            Text("\(feet)' \(inches)\"")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(DSColors.primary)

                            Slider(value: $viewModel.height, in: 39...98, step: 1)
                                .tint(DSColors.primary)

                            Text("\(feet) ft \(inches) in")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                    .padding()
                    .background(DSColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Weight (optional)
                    VStack(spacing: 12) {
                        Text("Weight (Optional)")
                            .font(DSTypography.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if viewModel.selectedUnitSystem == .metric {
                            Text("\(String(format: "%.1f", viewModel.weight)) kg")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(DSColors.primary)

                            Slider(value: $viewModel.weight, in: 30...200, step: 0.5)
                                .tint(DSColors.primary)
                        } else {
                            Text("\(Int(viewModel.weight)) lbs")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(DSColors.primary)

                            Slider(value: $viewModel.weight, in: 66...440, step: 1)
                                .tint(DSColors.primary)
                        }
                    }
                    .padding()
                    .background(DSColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Date of Birth (optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date of Birth (Optional)")
                            .font(DSTypography.callout)
                            .fontWeight(.semibold)

                        DatePicker(
                            "Date of Birth",
                            selection: $viewModel.dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()

                        if let age = viewModel.age {
                            Text("\(age) years old")
                                .font(DSTypography.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(DSColors.primary)
                        }
                    }
                    .padding()
                    .background(DSColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Gender (optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gender (Optional)")
                            .font(DSTypography.callout)
                            .fontWeight(.semibold)

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
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: viewModel.currentStep) { _, _ in
            // Dismiss keyboard when navigating to next step
            Task { @MainActor in
                focusedField = nil
            }
        }
    }

    // MARK: - Step 2: Fitness Level

    @ViewBuilder
    private func step2_FitnessLevel(viewModel vm: OnboardingViewModel) -> some View {
        @Bindable var viewModel = vm

        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("What's your fitness level?")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("This helps us recommend the right programs")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Selection cards
            VStack(spacing: 12) {
                ForEach(UserProfile.FitnessLevel.allCases, id: \.self) { level in
                    fitnessLevelCard(level: level, isSelected: viewModel.fitnessLevel == level) {
                        viewModel.fitnessLevel = level
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    @ViewBuilder
    private func fitnessLevelCard(level: UserProfile.FitnessLevel, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.rawValue)
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSelected ? .white : DSColors.textPrimary)

                        Text(fitnessLevelDescription(level))
                            .font(DSTypography.footnote)
                            .foregroundStyle(isSelected ? .white.opacity(0.9) : DSColors.textSecondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(isSelected ? DSColors.primary : DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func fitnessLevelDescription(_ level: UserProfile.FitnessLevel) -> String {
        switch level {
        case .beginner:
            return "0-1 years of training experience"
        case .intermediate:
            return "1-3 years, comfortable with compound lifts"
        case .advanced:
            return "3+ years, experienced with progressive programs"
        }
    }

    // MARK: - Step 3: Fitness Goals

    @ViewBuilder
    private func step3_FitnessGoals(viewModel vm: OnboardingViewModel) -> some View {
        @Bindable var viewModel = vm

        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundStyle(DSColors.primary)

                Text("What are your goals?")
                    .font(DSTypography.title2)
                    .fontWeight(.bold)

                Text("Select all that apply (min 1)")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Multi-select chips in flow layout
            VStack(spacing: 12) {
                ForEach(Array(UserProfile.FitnessGoal.allCases.enumerated()), id: \.element) { index, goal in
                    goalChip(
                        goal: goal,
                        isSelected: viewModel.selectedGoals.contains(goal),
                        action: { viewModel.toggleGoal(goal) }
                    )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    @ViewBuilder
    private func goalChip(goal: UserProfile.FitnessGoal, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: goalIcon(goal))
                    .font(DSTypography.callout)

                Text(goal.rawValue)
                    .font(DSTypography.callout)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(isSelected ? DSColors.primary : DSColors.cardBackground)
            .foregroundStyle(isSelected ? .white : DSColors.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? .clear : DSColors.separator, lineWidth: 1)
            )
        }
    }

    private func goalIcon(_ goal: UserProfile.FitnessGoal) -> String {
        switch goal {
        case .muscleGain:
            return "figure.arms.open"
        case .fatLoss:
            return "flame.fill"
        case .strength:
            return "bolt.fill"
        case .endurance:
            return "figure.run"
        }
    }

    // MARK: - Step 4: Frequency + Equipment

    @ViewBuilder
    private func step4_FrequencyEquipment(viewModel vm: OnboardingViewModel) -> some View {
        @Bindable var viewModel = vm

        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundStyle(DSColors.primary)

                    Text("Training Schedule & Activity")
                        .font(DSTypography.title2)
                        .fontWeight(.bold)

                    Text("Tell us about your lifestyle and setup")
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                VStack(spacing: 24) {
                    // Section 1: Frequency
                    VStack(spacing: 16) {
                        Text("How often can you train?")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 12) {
                            Text("\(viewModel.weeklyWorkoutFrequency) days")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(DSColors.primary)

                            Text("per week")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColors.textSecondary)

                            Picker("Frequency", selection: $viewModel.weeklyWorkoutFrequency) {
                                ForEach(2...7, id: \.self) { days in
                                    Text("\(days)").tag(days)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        }
                        .padding()
                        .background(DSColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Section 2: Activity Level
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's your daily activity level?")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)

                        VStack(spacing: 12) {
                            ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { activityOption in
                                activityLevelCard(
                                    activityLevel: activityOption,
                                    isSelected: viewModel.activityLevel == activityOption,
                                    action: { viewModel.activityLevel = activityOption }
                                )
                            }
                        }
                    }

                    // Section 3: Equipment
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What equipment do you have?")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)

                        VStack(spacing: 12) {
                            ForEach(UserProfile.Equipment.allCases, id: \.self) { equipmentOption in
                                equipmentCard(
                                    equipment: equipmentOption,
                                    isSelected: viewModel.equipment == equipmentOption,
                                    action: { viewModel.equipment = equipmentOption }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
    }

    @ViewBuilder
    private func equipmentCard(equipment: UserProfile.Equipment, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(equipment.rawValue)
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSelected ? .white : DSColors.textPrimary)

                        Text(equipmentDescription(equipment))
                            .font(DSTypography.footnote)
                            .foregroundStyle(isSelected ? .white.opacity(0.9) : DSColors.textSecondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(isSelected ? DSColors.primary : DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func equipmentDescription(_ equipment: UserProfile.Equipment) -> String {
        switch equipment {
        case .gym:
            return "Barbell, dumbbells, machines, cables"
        case .home:
            return "Basic equipment (barbell, dumbbells, bench)"
        case .minimal:
            return "Bodyweight only or resistance bands"
        }
    }

    @ViewBuilder
    private func activityLevelCard(activityLevel: UserProfile.ActivityLevel, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activityLevel.displayName)
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSelected ? .white : DSColors.textPrimary)

                        Text(activityLevelDescription(activityLevel))
                            .font(DSTypography.footnote)
                            .foregroundStyle(isSelected ? .white.opacity(0.9) : DSColors.textSecondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(isSelected ? DSColors.primary : DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func activityLevelDescription(_ activityLevel: UserProfile.ActivityLevel) -> String {
        switch activityLevel {
        case .sedentary:
            return "Little or no exercise, desk job"
        case .lightlyActive:
            return "Light exercise 1-3 days/week"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days/week"
        case .veryActive:
            return "Hard exercise 6-7 days/week"
        case .extraActive:
            return "Very hard exercise, physical job or 2x/day training"
        }
    }

    // MARK: - Step 5: Completion

    @ViewBuilder
    private func step5_Completion(viewModel: OnboardingViewModel) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .symbolEffect(.bounce)

            VStack(spacing: 12) {
                // Title
                Text("All Set!")
                    .font(DSTypography.largeTitle)
                    .foregroundStyle(DSColors.textPrimary)

                // Subtitle
                Text("Your AI Coach is ready to help")
                    .font(DSTypography.title3)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Summary card
            VStack(alignment: .leading, spacing: 16) {
                if !viewModel.name.isEmpty {
                    summaryRow(label: "Name", value: viewModel.name)
                }

                if let level = viewModel.fitnessLevel {
                    summaryRow(label: "Level", value: level.rawValue)
                }

                if !viewModel.selectedGoals.isEmpty {
                    let goalsText = viewModel.selectedGoals
                        .map { $0.rawValue }
                        .sorted()
                        .joined(separator: ", ")
                    summaryRow(label: "Goals", value: goalsText)
                }

                summaryRow(label: "Frequency", value: "\(viewModel.weeklyWorkoutFrequency) days/week")

                if let activityLevel = viewModel.activityLevel {
                    summaryRow(label: "Activity", value: activityLevel.displayName)
                }

                if let equipment = viewModel.equipment {
                    summaryRow(label: "Equipment", value: equipment.displayName)
                }
            }
            .padding()
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Spacer()

            // CTA Button
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    DSPrimaryButton(title: "Start Training") {
                        Task {
                            do {
                                try await viewModel.completeOnboarding()
                                onComplete()
                            } catch {
                                print("❌ Failed to complete onboarding: \(error)")
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(DSTypography.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private func summaryRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(DSTypography.callout)
                .foregroundStyle(DSColors.textSecondary)

            Spacer()

            Text(value)
                .font(DSTypography.callout)
                .fontWeight(.semibold)
                .foregroundStyle(DSColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Basic Info Field Focus

private enum BasicInfoField {
    case name
}

// MARK: - Preview

#Preview {
    OnboardingWizardView(
        userProfileRepository: AppDependencies.preview.userProfileRepository,
        onComplete: { print("Onboarding completed") }
    )
}
