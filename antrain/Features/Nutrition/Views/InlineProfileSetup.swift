//
//  InlineProfileSetup.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// Inline setup for missing profile data within TDEE calculator
struct InlineProfileSetup: View {
    let profile: UserProfile?
    let onSave: () async throws -> Void

    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var height: Double = 170.0
    @State private var weight: Double = 70.0
    @State private var gender: UserProfile.Gender = .male
    @State private var activityLevel: UserProfile.ActivityLevel = .moderatelyActive
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Complete your profile to see personalized TDEE")
                .font(DSTypography.body)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                // Age (if missing)
                if profile?.age == nil {
                    MissingDataField(
                        title: "Age",
                        icon: "calendar"
                    ) {
                        DatePicker(
                            "Date of Birth",
                            selection: $dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)

                        if let age = calculateAge(from: dateOfBirth) {
                            Text("\(age) years old")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }

                // Height (if missing)
                if profile?.height == nil {
                    MissingDataField(
                        title: "Height",
                        icon: "ruler"
                    ) {
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(Int(height)) cm")
                                    .font(DSTypography.body)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            Slider(value: $height, in: 100...250, step: 1)
                                .tint(DSColors.primary)
                        }
                    }
                }

                // Weight (if missing)
                if profile?.currentBodyweight == nil {
                    MissingDataField(
                        title: "Current Weight",
                        icon: "scalemass"
                    ) {
                        VStack(spacing: 8) {
                            HStack {
                                Text(String(format: "%.1f kg", weight))
                                    .font(DSTypography.body)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            Slider(value: $weight, in: 30...200, step: 0.5)
                                .tint(DSColors.primary)
                        }
                    }
                }

                // Gender (if missing)
                if profile?.gender == nil {
                    MissingDataField(
                        title: "Gender",
                        icon: "person"
                    ) {
                        Picker("Gender", selection: $gender) {
                            ForEach(UserProfile.Gender.allCases, id: \.self) { g in
                                Text(g.rawValue).tag(g)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // Activity Level (if missing)
                if profile?.activityLevel == nil {
                    MissingDataField(
                        title: "Activity Level",
                        icon: "figure.run"
                    ) {
                        VStack(spacing: 8) {
                            Picker("Activity", selection: $activityLevel) {
                                ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.menu)

                            if let tdeeLevel = TDEECalculator.ActivityLevel(rawValue: activityLevel.rawValue) {
                                Text(tdeeLevel.description)
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                            }
                        }
                    }
                }
            }

            // Save button
            Button {
                Task {
                    await saveData()
                }
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isSaving ? "Saving..." : "Save & Calculate TDEE")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(DSColors.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isSaving)

            if let errorMessage {
                Text(errorMessage)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.error)
            }
        }
        .padding()
        .background(DSColors.warning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DSColors.warning.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            loadExistingData()
        }
    }

    private func loadExistingData() {
        if let profile = profile {
            if let dob = profile.dateOfBirth {
                dateOfBirth = dob
            }
            if let h = profile.height {
                height = h
            }
            if let w = profile.currentBodyweight?.weight {
                weight = w
            }
            if let g = profile.gender {
                gender = g
            }
            if let a = profile.activityLevel {
                activityLevel = a
            }
        }
    }

    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }

    private func saveData() async {
        isSaving = true
        errorMessage = nil

        do {
            // Update profile
            if let profile = profile {
                profile.update(
                    height: profile.height == nil ? height : nil,
                    gender: profile.gender == nil ? gender : nil,
                    dateOfBirth: profile.dateOfBirth == nil ? dateOfBirth : nil,
                    activityLevel: profile.activityLevel == nil ? activityLevel : nil
                )
            }

            // Call parent save
            try await onSave()

            isSaving = false
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

/// Individual missing data field with expand/collapse
private struct MissingDataField<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(DSColors.warning)
                        .frame(width: 20)

                    Text(title)
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.textPrimary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }
                .padding()
                .background(DSColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if isExpanded {
                content
                    .padding()
                    .background(DSColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 4)
            }
        }
    }
}
