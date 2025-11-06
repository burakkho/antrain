//
//  TemplateSetConfigView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Step 3: Configure sets, reps, and notes for each exercise
struct TemplateSetConfigView: View {
    @Bindable var viewModel: CreateTemplateViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Info banner
                infoBanner

                // Exercise configurations
                ForEach(Array(viewModel.exerciseConfigs.enumerated()), id: \.element.id) { index, config in
                    ExerciseConfigCard(
                        config: config,
                        index: index + 1,
                        categoryDefaults: (
                            sets: viewModel.selectedCategory.defaultSetCount,
                            repMin: viewModel.selectedCategory.defaultRepRangeMin,
                            repMax: viewModel.selectedCategory.defaultRepRangeMax
                        ),
                        onUpdate: { setCount, repMin, repMax, notes in
                            viewModel.updateConfig(
                                for: config.exercise.id,
                                setCount: setCount,
                                repMin: repMin,
                                repMax: repMax,
                                notes: notes
                            )
                        },
                        onUseDefaults: {
                            viewModel.useDefaultConfig(for: config.exercise.id)
                        }
                    )
                }
            }
            .padding()
            .padding(.bottom, 80) // Extra padding for navigation buttons
        }
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Configure Each Exercise")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Set the number of sets and rep ranges. You can use category defaults or customize each exercise.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Exercise Config Card

private struct ExerciseConfigCard: View {
    let config: ExerciseConfig
    let index: Int
    let categoryDefaults: (sets: Int, repMin: Int, repMax: Int)
    let onUpdate: (Int?, Int?, Int?, String?) -> Void
    let onUseDefaults: () -> Void

    @State private var setCount: Int
    @State private var repMin: Int
    @State private var repMax: Int
    @State private var notes: String

    init(
        config: ExerciseConfig,
        index: Int,
        categoryDefaults: (sets: Int, repMin: Int, repMax: Int),
        onUpdate: @escaping (Int?, Int?, Int?, String?) -> Void,
        onUseDefaults: @escaping () -> Void
    ) {
        self.config = config
        self.index = index
        self.categoryDefaults = categoryDefaults
        self.onUpdate = onUpdate
        self.onUseDefaults = onUseDefaults

        _setCount = State(initialValue: config.setCount)
        _repMin = State(initialValue: config.repRangeMin)
        _repMax = State(initialValue: config.repRangeMax)
        _notes = State(initialValue: config.notes ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Exercise header
            HStack {
                Text("\(index).")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, alignment: .leading)

                Text(config.exercise.name)
                    .font(.headline)

                Spacer()

                // Use defaults button
                Button {
                    onUseDefaults()
                    // Update local state
                    setCount = categoryDefaults.sets
                    repMin = categoryDefaults.repMin
                    repMax = categoryDefaults.repMax
                    notes = ""
                } label: {
                    Text("Defaults")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            // Set count
            VStack(alignment: .leading, spacing: 8) {
                Text("Sets")
                    .font(.subheadline)
                    .fontWeight(.medium)

                VStack(spacing: 8) {
                    // First row: 1-5
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { count in
                            setButton(count: count)
                        }
                    }

                    // Second row: 6-10
                    HStack(spacing: 8) {
                        ForEach(6...10, id: \.self) { count in
                            setButton(count: count)
                        }
                    }
                }
            }

            // Rep range
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Rep Range")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    // Rep range display
                    Text("\(repMin)-\(repMax) reps")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                }

                HStack(spacing: 12) {
                    // Min reps
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Min")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Stepper(value: $repMin, in: 1...50, step: 1) {
                            Text("\(repMin)")
                                .font(.headline)
                                .frame(width: 40, alignment: .center)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .onChange(of: repMin) { _, newValue in
                            if newValue > repMax {
                                repMax = newValue
                            }
                            onUpdate(nil, newValue, nil, nil)
                        }
                    }

                    Text("—")
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)

                    // Max reps
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Stepper(value: $repMax, in: repMin...50, step: 1) {
                            Text("\(repMax)")
                                .font(.headline)
                                .frame(width: 40, alignment: .center)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .onChange(of: repMax) { _, newValue in
                            onUpdate(nil, nil, newValue, nil)
                        }
                    }
                }
            }

            // Notes (optional)
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("e.g., Dropset on last set", text: $notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .onChange(of: notes) { _, newValue in
                        onUpdate(nil, nil, nil, newValue)
                    }
            }

            // Validation indicator
            if !config.isValid {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("Invalid configuration")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func setButton(count: Int) -> some View {
        Button {
            setCount = count
            onUpdate(count, nil, nil, nil)
        } label: {
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(setCount == count ? .semibold : .regular)
                .foregroundStyle(setCount == count ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    setCount == count ? Color.accentColor : Color(.secondarySystemBackground)
                )
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = CreateTemplateViewModel(
        templateRepository: AppDependencies.preview.workoutTemplateRepository,
        exerciseRepository: AppDependencies.preview.exerciseRepository
    )

    // Setup some test data
    viewModel.selectedCategory = .hypertrophy
    viewModel.selectedExercises = [
        Exercise(
            name: "Barbell Bench Press",
            category: .barbell,
            muscleGroups: [.chest],
            equipment: .barbell,
            isCustom: false
        ),
        Exercise(
            name: "Dumbbell Row",
            category: .dumbbell,
            muscleGroups: [.back],
            equipment: .dumbbell,
            isCustom: false
        )
    ]

    return NavigationStack {
        TemplateSetConfigView(viewModel: viewModel)
            .navigationTitle("Configure Sets")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Trigger config preparation
                viewModel.goToStep(.configuration)
            }
    }
}
