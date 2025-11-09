import SwiftUI

/// Expandable card showing PR for a specific exercise
struct ExercisePRCard: View {
    let exerciseName: String
    let prHistory: [PersonalRecord]
    let weightUnit: String
    let isExpanded: Bool
    let onTap: () -> Void

    @State private var selectedPR: PersonalRecord?

    private var currentPR: PersonalRecord? {
        prHistory.max(by: { $0.estimated1RM < $1.estimated1RM })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button(action: onTap) {
                HStack(spacing: DSSpacing.sm) {
                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.title3)
                        .foregroundStyle(DSColors.primary)
                        .frame(width: 32)

                    // Exercise info
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(exerciseName)
                            .font(DSTypography.headline)
                            .foregroundStyle(DSColors.textPrimary)

                        if let pr = currentPR {
                            Text(pr.relativeDate)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textTertiary)
                        }
                    }

                    Spacer()

                    // 1RM value
                    if let pr = currentPR {
                        VStack(alignment: .trailing, spacing: DSSpacing.xxs) {
                            Text(pr.formattedWeight(weightUnit: weightUnit))
                                .font(DSTypography.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(DSColors.primary)

                            Text("\(pr.actualWeight.formatted()) × \(pr.reps)")
                                .font(DSTypography.caption2)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(DSColors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(DSSpacing.md)
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Divider()

                    // Chart
                    ExercisePRHistoryChart(
                        prHistory: prHistory.sorted { $0.date < $1.date },
                        weightUnit: weightUnit,
                        selectedPR: $selectedPR
                    )
                    .padding(.horizontal, DSSpacing.md)

                    // PR History List
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("PR History")
                            .font(DSTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DSColors.textPrimary)
                            .padding(.horizontal, DSSpacing.md)

                        VStack(spacing: DSSpacing.xxs) {
                            let sortedPRs = prHistory.sorted { $0.date > $1.date }
                            ForEach(Array(sortedPRs.enumerated()), id: \.element.id) { index, pr in
                                let previousPR = index < sortedPRs.count - 1 ? sortedPRs[index + 1] : nil
                                NavigationLink(value: pr.workoutId) {
                                    PRHistoryRow(
                                        pr: pr,
                                        previousPR: previousPR,
                                        weightUnit: weightUnit
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, DSSpacing.md)
                    }
                }
                .padding(.bottom, DSSpacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .strokeBorder(DSColors.primary.opacity(0.2), lineWidth: 1)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }
}

// MARK: - PR History Row

private struct PRHistoryRow: View {
    let pr: PersonalRecord
    let previousPR: PersonalRecord?
    let weightUnit: String

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(pr.date, format: .dateTime.month(.abbreviated).day())
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)

                Text(pr.date, format: .dateTime.year())
                    .font(DSTypography.caption2)
                    .foregroundStyle(DSColors.textTertiary)
            }
            .frame(width: 50, alignment: .leading)

            // 1RM with percentage gain
            VStack(alignment: .leading, spacing: 2) {
                Text("Est. 1RM")
                    .font(DSTypography.caption2)
                    .foregroundStyle(DSColors.textTertiary)

                HStack(spacing: DSSpacing.xxs) {
                    Text(pr.formattedWeight(weightUnit: weightUnit))
                        .font(DSTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColors.primary)

                    if let previousPR {
                        let gain = pr.percentGain(from: previousPR)
                        Text(pr.formattedPercentGain(from: previousPR))
                            .font(DSTypography.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(gain >= 0 ? .green : .red)
                    }
                }
            }

            Spacer()

            // Actual set
            VStack(alignment: .trailing, spacing: 2) {
                Text("Actual Set")
                    .font(DSTypography.caption2)
                    .foregroundStyle(DSColors.textTertiary)

                Text("\(pr.actualWeight.formatted()) × \(pr.reps)")
                    .font(DSTypography.subheadline)
                    .foregroundStyle(DSColors.textSecondary)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(DSColors.textTertiary)
        }
        .padding(.vertical, DSSpacing.xs)
        .padding(.horizontal, DSSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                .fill(Color.primary.opacity(0.05))
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isExpanded = true

    let samplePRs = [
        PersonalRecord(
            exerciseName: "Bench Press",
            exerciseId: UUID(),
            estimated1RM: 100,
            actualWeight: 90,
            reps: 5,
            date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            workoutId: UUID()
        ),
        PersonalRecord(
            exerciseName: "Bench Press",
            exerciseId: UUID(),
            estimated1RM: 105,
            actualWeight: 95,
            reps: 5,
            date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            workoutId: UUID()
        ),
        PersonalRecord(
            exerciseName: "Bench Press",
            exerciseId: UUID(),
            estimated1RM: 115,
            actualWeight: 105,
            reps: 5,
            date: Date(),
            workoutId: UUID()
        )
    ]

    ScrollView {
        VStack(spacing: DSSpacing.md) {
            ExercisePRCard(
                exerciseName: "Bench Press",
                prHistory: samplePRs,
                weightUnit: "Kilograms",
                isExpanded: isExpanded,
                onTap: { isExpanded.toggle() }
            )

            ExercisePRCard(
                exerciseName: "Squat",
                prHistory: samplePRs,
                weightUnit: "Kilograms",
                isExpanded: false,
                onTap: { }
            )
        }
        .padding()
    }
}
