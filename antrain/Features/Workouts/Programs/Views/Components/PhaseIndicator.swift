//
//  PhaseIndicator.swift
//  antrain
//
//  Created by Claude Code on 2025-11-05.
//

import SwiftUI

/// Visual indicator for training phase
struct PhaseIndicator: View {
    let phase: TrainingPhase
    var style: Style = .default

    enum Style {
        case `default`
        case compact
        case badge
    }

    var body: some View {
        switch style {
        case .default:
            defaultStyle
        case .compact:
            compactStyle
        case .badge:
            badgeStyle
        }
    }

    private var defaultStyle: some View {
        HStack(spacing: 8) {
            Image(systemName: phase.iconName)
                .font(.body)
                .foregroundStyle(phase.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(phase.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(phaseDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(phase.color.opacity(0.1))
        }
    }

    private var compactStyle: some View {
        HStack(spacing: 6) {
            Image(systemName: phase.iconName)
                .font(.caption)
            Text(phase.displayName)
                .font(.caption)
        }
        .foregroundStyle(phase.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(phase.color.opacity(0.15))
        }
    }

    private var badgeStyle: some View {
        Image(systemName: phase.iconName)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(6)
            .background {
                Circle()
                    .fill(phase.color)
            }
    }

    private var phaseDescription: String {
        switch phase {
        case .hypertrophy:
            return String(localized: "Muscle building focus")
        case .strength:
            return String(localized: "Strength development")
        case .peaking:
            return String(localized: "Maximum performance")
        case .deload:
            return String(localized: "Recovery and adaptation")
        case .testing:
            return String(localized: "Max effort testing")
        }
    }
}

#Preview("All Phases - Default") {
    VStack(spacing: 12) {
        ForEach(TrainingPhase.allCases, id: \.self) { phase in
            PhaseIndicator(phase: phase, style: .default)
        }
    }
    .padding()
}

#Preview("All Phases - Compact") {
    VStack(spacing: 8) {
        ForEach(TrainingPhase.allCases, id: \.self) { phase in
            PhaseIndicator(phase: phase, style: .compact)
        }
    }
    .padding()
}

#Preview("All Phases - Badge") {
    HStack(spacing: 12) {
        ForEach(TrainingPhase.allCases, id: \.self) { phase in
            PhaseIndicator(phase: phase, style: .badge)
        }
    }
    .padding()
}
