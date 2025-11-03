//
//  TemplateCategoryFilterView.swift
//  antrain
//
//  Created on 2025-11-03.
//

import SwiftUI

/// Horizontal scrolling category filter chips
struct TemplateCategoryFilterView: View {
    let selectedCategory: TemplateCategory?
    let onSelect: (TemplateCategory?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .primary,
                    isSelected: selectedCategory == nil
                ) {
                    onSelect(nil)
                }

                // Category chips
                ForEach(TemplateCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Filter Chip Component

private struct FilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? color : color.opacity(0.15),
                in: Capsule()
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        TemplateCategoryFilterView(
            selectedCategory: nil,
            onSelect: { _ in }
        )

        TemplateCategoryFilterView(
            selectedCategory: .hypertrophy,
            onSelect: { _ in }
        )
    }
}
