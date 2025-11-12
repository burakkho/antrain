//
//  QuickActionChips.swift
//  antrain
//
//  Created by AI Coach Feature
//

import SwiftUI

struct QuickActionChips: View {
    let context: WorkoutContext?
    let isNewUser: Bool
    let onChipTap: (String) -> Void

    // ✅ CACHE: Only recompute when context or isNewUser changes
    @State private var cachedActions: [QuickAction] = []

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(cachedActions) { action in
                    ChipButton(action: action) {
                        onChipTap(action.message)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
        }
        .onAppear {
            // Initial computation
            cachedActions = buildActions(context: context, isNewUser: isNewUser)
        }
        .onChange(of: context?.hasActiveProgram) { _, _ in
            // Recompute when program status changes
            cachedActions = buildActions(context: context, isNewUser: isNewUser)
        }
        .onChange(of: context?.recentWorkouts.count ?? 0) { _, _ in
            // Recompute when workout count changes (new workouts logged)
            cachedActions = buildActions(context: context, isNewUser: isNewUser)
        }
        .onChange(of: isNewUser) { _, _ in
            // Recompute when user status changes (profile completed)
            cachedActions = buildActions(context: context, isNewUser: isNewUser)
        }
    }

    // MARK: - Context-Aware Actions

    /// Builds action list based on context
    /// Only called when context or isNewUser actually changes
    private func buildActions(context: WorkoutContext?, isNewUser: Bool) -> [QuickAction] {
        var actions: [QuickAction] = []

        // NEW USER - Onboarding Actions
        if isNewUser {
            actions.append(contentsOf: [
                QuickAction(
                    icon: "hand.wave.fill",
                    title: "Get Started",
                    message: "Hi! I'm new here, help me get started"
                ),
                QuickAction(
                    icon: "figure.strengthtraining.traditional",
                    title: "Program Suggestion",
                    message: "Can you suggest a workout program for me?"
                ),
                QuickAction(
                    icon: "fork.knife",
                    title: "Nutrition Help",
                    message: "How should I set my nutrition goals?"
                ),
                QuickAction(
                    icon: "questionmark.circle.fill",
                    title: "App Guide",
                    message: "How do I use this app?"
                )
            ])
            return actions
        }

        guard let context = context else {
            return defaultActions
        }

        // DELOAD WEEK - Recovery Focus
        if context.currentWeekIsDeload == true {
            actions.append(contentsOf: [
                QuickAction(
                    icon: "bed.double.fill",
                    title: "Deload Tips",
                    message: "I'm in a deload week, what should I focus on?"
                ),
                QuickAction(
                    icon: "heart.fill",
                    title: "Recovery",
                    message: "How can I maximize recovery this week?"
                )
            ])
        }

        // RECENT PR - Celebration
        if context.recentPRCount > 0 {
            actions.append(
                QuickAction(
                    icon: "trophy.fill",
                    title: "My PRs",
                    message: "Tell me about my recent personal records!"
                )
            )
        }

        // NO ACTIVE PROGRAM - Suggest Programs
        if !context.hasActiveProgram {
            actions.append(
                QuickAction(
                    icon: "calendar.badge.plus",
                    title: "Start Program",
                    message: "Suggest a training program for me"
                )
            )
        } else {
            // HAS PROGRAM - Current Week
            actions.append(
                QuickAction(
                    icon: "calendar",
                    title: "This Week",
                    message: "What's my program this week?"
                )
            )

            // PROGRAM ALMOST DONE
            if let current = context.currentWeekNumber,
               let total = context.totalProgramWeeks,
               current >= total - 1 {
                actions.append(
                    QuickAction(
                        icon: "flag.checkered",
                        title: "Next Program?",
                        message: "My program is ending soon, what should I do next?"
                    )
                )
            }
        }

        // VOLUME TREND - Progress Check
        if abs(context.volumeTrend) > 10 {
            let trend = context.volumeTrend > 0 ? "up" : "down"
            actions.append(
                QuickAction(
                    icon: context.volumeTrend > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    title: "Volume Trend",
                    message: "My volume is \(trend), what does this mean?"
                )
            )
        }

        // LOW TRAINING FREQUENCY
        if context.trainingFrequency < 3 {
            actions.append(
                QuickAction(
                    icon: "exclamationmark.triangle.fill",
                    title: "Frequency Low",
                    message: "I'm only training \(Int(context.trainingFrequency)) times per week, should I increase?"
                )
            )
        }

        // NUTRITION ADHERENCE
        if let adherence = context.nutritionAdherence, adherence < 0.5 {
            actions.append(
                QuickAction(
                    icon: "fork.knife.circle.fill",
                    title: "Nutrition Help",
                    message: "My nutrition tracking is inconsistent, how can I improve?"
                )
            )
        } else if context.nutritionAdherence != nil {
            actions.append(
                QuickAction(
                    icon: "fork.knife",
                    title: "Nutrition Review",
                    message: "How's my nutrition looking?"
                )
            )
        }

        // BODYWEIGHT TREND
        if let trend = context.bodyweightTrend, trend != "stable" {
            actions.append(
                QuickAction(
                    icon: "scalemass.fill",
                    title: "Weight Trend",
                    message: "My weight trend is \(trend), is this good?"
                )
            )
        }

        // WORKOUT HISTORY - Recent Activity
        if context.hasWorkoutHistory {
            actions.append(
                QuickAction(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress Check",
                    message: "Analyze my progress and give me feedback"
                )
            )
        }

        // FORM ADVICE - Always useful
        actions.append(
            QuickAction(
                icon: "figure.mind.and.body",
                title: "Form Tips",
                message: "Give me exercise form tips"
            )
        )

        // MOTIVATION - Always available
        actions.append(
            QuickAction(
                icon: "sparkles",
                title: "Motivate Me",
                message: "Give me some motivation!"
            )
        )

        // TODAY'S WORKOUT
        if context.hasActiveProgram {
            actions.append(
                QuickAction(
                    icon: "calendar.badge.clock",
                    title: "Today's Plan",
                    message: "What should I do for today's workout?"
                )
            )
        }

        // EQUIPMENT-SPECIFIC (if user has equipment preference)
        if let equipment = context.availableEquipment, equipment != "Gym" {
            actions.append(
                QuickAction(
                    icon: "house.fill",
                    title: "\(equipment) Workout",
                    message: "Suggest a workout with \(equipment.lowercased()) equipment"
                )
            )
        }

        // GOAL-SPECIFIC
        if !context.fitnessGoals.isEmpty {
            let primaryGoal = context.fitnessGoals.first ?? "Muscle Gain"
            let icon = goalIcon(for: primaryGoal)
            actions.append(
                QuickAction(
                    icon: icon,
                    title: "\(primaryGoal) Tips",
                    message: "Give me tips for \(primaryGoal.lowercased())"
                )
            )
        }

        // Limit to 15 actions to avoid overwhelming user
        return Array(actions.prefix(15))
    }

    // MARK: - Default Actions (Fallback)

    private var defaultActions: [QuickAction] {
        [
            QuickAction(
                icon: "figure.strengthtraining.traditional",
                title: "My Program?",
                message: "What's my program this week?"
            ),
            QuickAction(
                icon: "trophy.fill",
                title: "My PRs?",
                message: "What are my personal records?"
            ),
            QuickAction(
                icon: "fork.knife",
                title: "Nutrition?",
                message: "How's my nutrition?"
            ),
            QuickAction(
                icon: "chart.line.uptrend.xyaxis",
                title: "Progress",
                message: "Analyze my progress"
            ),
            QuickAction(
                icon: "figure.mind.and.body",
                title: "Form Tips",
                message: "Give me exercise form tips"
            )
        ]
    }

    // MARK: - Helper Functions

    private func goalIcon(for goal: String) -> String {
        switch goal {
        case "Muscle Gain":
            return "figure.arms.open"
        case "Fat Loss":
            return "flame.fill"
        case "Strength":
            return "bolt.fill"
        case "Endurance":
            return "figure.run"
        default:
            return "star.fill"
        }
    }
}

// MARK: - Quick Action Model

private struct QuickAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
}

// MARK: - Chip Button

private struct ChipButton: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            onTap()
        }) {
            HStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.system(size: 14))

                Text(action.title)
                    .font(DSTypography.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(DSColors.primary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background {
                Capsule()
                    .fill(.regularMaterial)
                    .overlay(
                        Capsule()
                            .strokeBorder(DSColors.primary.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        QuickActionChips(
            context: nil,
            isNewUser: false
        ) { message in
            print("Tapped: \(message)")
        }
        Spacer()
    }
}
