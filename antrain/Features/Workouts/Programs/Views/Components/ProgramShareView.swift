//
//  ProgramShareView.swift
//  antrain
//
//  Share view for training programs
//

import SwiftUI

/// Share view for training programs
struct ProgramShareView: View {
    @Environment(\.dismiss) private var dismiss

    let program: TrainingProgram

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Program summary
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    VStack(spacing: 8) {
                        Text(program.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("\(program.category.displayName) • \(program.difficulty.displayName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("\(program.durationWeeks) weeks • \(String(format: "%.0f", program.trainingDaysPerWeek)) days/week")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                Divider()

                // Share options
                VStack(alignment: .leading, spacing: 16) {
                    Text("Share Program", comment: "Share program section title")
                        .font(.headline)
                        .padding(.horizontal)

                    // Share as text
                    ShareLink(
                        item: programAsText,
                        subject: Text("Training Program: \(program.name)"),
                        message: Text("Check out this training program!")
                    ) {
                        Label("Share as Text", systemImage: "text.quote")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    // Copy to clipboard
                    Button {
                        UIPasteboard.general.string = programAsText
                        dismiss()
                    } label: {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Share Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var programAsText: String {
        var text = """
        📋 \(program.name)

        Category: \(program.category.displayName)
        Difficulty: \(program.difficulty.displayName)
        Duration: \(program.durationWeeks) weeks
        Training Days: \(String(format: "%.0f", program.trainingDaysPerWeek)) days/week
        Progression: \(program.progressionPattern.displayName)

        """

        if let description = program.programDescription {
            text += """
            Description:
            \(description)

            """
        }

        text += """
        Weekly Schedule:

        """

        // Add weeks
        for week in program.weeks.sorted() {
            text += """
            Week \(week.weekNumber)\(week.isDeload ? " (Deload)" : "")
            Intensity: \(Int(week.intensityModifier * 100))%

            """

            // Add days
            for day in week.days.sorted(by: { $0.dayOfWeek < $1.dayOfWeek }) {
                let dayName = Calendar.current.weekdaySymbols[day.dayOfWeek - 1]
                if let template = day.template {
                    text += "  \(dayName): \(template.name)\n"
                } else {
                    text += "  \(dayName): Rest\n"
                }
            }
            text += "\n"
        }

        text += """

        ---
        Created with AnTrain - Your Personal Training Companion
        """

        return text
    }
}

// MARK: - Preview

#Preview {
    let program = TrainingProgram(
        name: "Push Pull Legs",
        category: .bodybuilding,
        difficulty: .intermediate,
        durationWeeks: 12
    )

    return ProgramShareView(program: program)
}
