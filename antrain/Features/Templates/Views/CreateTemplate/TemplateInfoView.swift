//
//  TemplateInfoView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Step 1: Template name and category selection
struct TemplateInfoView: View {
    @Bindable var viewModel: CreateTemplateViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Template Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Template Name")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    TextField("e.g., Push Day", text: $viewModel.templateName)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    if !viewModel.templateName.isEmpty && !viewModel.isStep1Valid {
                        Text("Name cannot be empty")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                // Category Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.setCategory(category)
                            }
                        }
                    }
                }

                // Category Description
                if let category = TemplateCategory.allCases.first(where: { $0 == viewModel.selectedCategory }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(category.color)
                            Text("About this category")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Text(category.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Default config info
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Default Sets")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                Text("\(category.defaultSetCount)")
                                    .font(.headline)
                                    .foregroundStyle(category.color)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Default Reps")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                Text("\(category.defaultRepRangeMin)-\(category.defaultRepRangeMax)")
                                    .font(.headline)
                                    .foregroundStyle(category.color)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(category.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let category: TemplateCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(isSelected ? .white : category.color)

                // Name
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                isSelected ? category.color : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(category.color, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TemplateInfoView(
            viewModel: CreateTemplateViewModel(
                templateRepository: AppDependencies.preview.workoutTemplateRepository,
                exerciseRepository: AppDependencies.preview.exerciseRepository
            )
        )
        .navigationTitle("Template Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}
