import SwiftUI
import Charts

/// Chart showing PR history progression for a specific exercise
struct ExercisePRHistoryChart: View {
    let prHistory: [PersonalRecord]
    let weightUnit: String
    @Binding var selectedPR: PersonalRecord?
    @State private var selectedDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Chart
            Chart {
                ForEach(prHistory) { pr in
                    LineMark(
                        x: .value("Date", pr.date),
                        y: .value("1RM", pr.estimated1RM)
                    )
                    .foregroundStyle(DSColors.primary.gradient)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", pr.date),
                        y: .value("1RM", pr.estimated1RM)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColors.primary.opacity(0.3), DSColors.primary.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", pr.date),
                        y: .value("1RM", pr.estimated1RM)
                    )
                    .foregroundStyle(DSColors.primary)
                    .symbolSize(selectedDate == pr.date ? 100 : 60)
                }

                // Rule mark for selected point
                if let selectedDate {
                    RuleMark(x: .value("Selected", selectedDate))
                        .foregroundStyle(DSColors.primary.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(DSTypography.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let weight = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatWeight(weight))
                                .font(DSTypography.caption2)
                        }
                    }
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(height: 200)
            .padding(.vertical, DSSpacing.xs)
            .onChange(of: selectedDate) { _, newDate in
                if let newDate {
                    self.selectedPR = prHistory.first { Calendar.current.isDate($0.date, inSameDayAs: newDate) }
                }
            }

            // Selected PR details card
            if let selectedPR {
                NavigationLink(value: selectedPR.workoutId) {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text(selectedPR.date, style: .date)
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)

                                HStack(spacing: DSSpacing.xs) {
                                    Text("1RM:")
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textTertiary)

                                    Text(selectedPR.formattedWeight(weightUnit: weightUnit))
                                        .font(DSTypography.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(DSColors.primary)

                                    Text("•")
                                        .foregroundStyle(DSColors.textTertiary)

                                    Text("\(selectedPR.actualWeight.formatted()) × \(selectedPR.reps)")
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                            }

                            Spacer()

                            // Dismiss button
                            Button {
                                withAnimation {
                                    self.selectedPR = nil
                                    self.selectedDate = nil
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(DSColors.textTertiary)
                            }
                        }

                        // View Workout button
                        HStack {
                            Text("View Workout")
                                .font(DSTypography.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(DSColors.primary)

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(DSColors.primary)
                        }
                        .padding(.vertical, DSSpacing.xs)
                        .padding(.horizontal, DSSpacing.sm)
                        .background {
                            RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                                .fill(DSColors.primary.opacity(0.1))
                        }
                    }
                    .padding(DSSpacing.sm)
                    .background {
                        RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                }
                .buttonStyle(.plain)
            }

            // Progress stats
            if prHistory.count >= 2 {
                HStack(spacing: DSSpacing.md) {
                    ProgressStat(
                        label: "First",
                        value: formatWeight(prHistory.first?.estimated1RM ?? 0)
                    )

                    Divider()
                        .frame(height: 30)

                    ProgressStat(
                        label: "Latest",
                        value: formatWeight(prHistory.last?.estimated1RM ?? 0)
                    )

                    Divider()
                        .frame(height: 30)

                    ProgressStat(
                        label: "Gain",
                        value: formatWeightDiff(),
                        isPositive: true
                    )
                }
                .padding(DSSpacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                        .fill(.regularMaterial)
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatWeight(_ weight: Double) -> String {
        if weightUnit == "Pounds" {
            let pounds = weight * 2.20462
            return "\(Int(pounds.rounded())) lb"
        } else {
            return "\(Int(weight.rounded())) kg"
        }
    }

    private func formatWeightDiff() -> String {
        guard let first = prHistory.first?.estimated1RM,
              let last = prHistory.last?.estimated1RM else {
            return "—"
        }

        let diff = last - first
        let percentage = (diff / first) * 100

        if weightUnit == "Pounds" {
            let poundsDiff = diff * 2.20462
            return "+\(Int(poundsDiff.rounded())) lb (+\(Int(percentage))%)"
        } else {
            return "+\(Int(diff.rounded())) kg (+\(Int(percentage))%)"
        }
    }
}

// MARK: - Progress Stat

private struct ProgressStat: View {
    let label: LocalizedStringKey
    let value: String
    var isPositive: Bool = false

    var body: some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(label)
                .font(DSTypography.caption2)
                .foregroundStyle(DSColors.textTertiary)

            Text(value)
                .font(DSTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isPositive ? .green : DSColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedPR: PersonalRecord? = nil

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
            estimated1RM: 110,
            actualWeight: 100,
            reps: 5,
            date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
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
        VStack {
            ExercisePRHistoryChart(
                prHistory: samplePRs,
                weightUnit: "Kilograms",
                selectedPR: $selectedPR
            )
            .padding()
        }
    }
}
