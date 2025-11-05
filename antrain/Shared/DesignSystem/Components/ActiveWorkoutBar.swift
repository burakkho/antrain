import SwiftUI

/// Persistent bar showing active workout status
/// Displayed above tab bar when workout is in progress
struct ActiveWorkoutBar: View {
    let manager: ActiveWorkoutManager
    @State private var showFinishConfirmation = false
    @State private var dragOffset: CGFloat = 0
    @State private var screenHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                barContent
            }
            .offset(y: calculateYPosition(for: geometry.size.height) + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        snapToNearestPosition(dragHeight: value.translation.height, screenHeight: geometry.size.height)
                    }
            )
            .onAppear {
                screenHeight = geometry.size.height
            }
        }
    }

    private var barContent: some View {
        VStack(spacing: 0) {
            // Main bar content
            HStack(spacing: DSSpacing.xs) {
                // Icon
                Image(systemName: "dumbbell.fill")
                    .font(.body)
                    .foregroundStyle(DSColors.primary)

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout in Progress")
                        .font(.caption2)
                        .foregroundStyle(DSColors.textSecondary)

                    if let exerciseName = manager.activeExerciseName {
                        Text("\(exerciseName) • \(manager.completedSets)/\(manager.totalSets) sets")
                            .font(.footnote)
                            .foregroundStyle(DSColors.textPrimary)
                            .lineLimit(1)
                    } else {
                        Text("\(manager.completedSets)/\(manager.totalSets) sets")
                            .font(.footnote)
                            .foregroundStyle(DSColors.textPrimary)
                    }
                }

                Spacer()

                // Action buttons
                HStack(spacing: DSSpacing.xs) {
                    // View button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            manager.resumeWorkout()
                        }
                    } label: {
                        Text("View")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(DSColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
                    }

                    // Finish button
                    Button {
                        showFinishConfirmation = true
                    } label: {
                        Text("Finish")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(DSColors.error)
                            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.sm))
                    }
                }
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.lg))
            .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
            .padding(.horizontal, DSSpacing.md)
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    manager.resumeWorkout()
                }
            }
            .confirmationDialog(
                "Finish Workout?",
                isPresented: $showFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button("Finish", role: .destructive) {
                    manager.activeViewModel?.showSummary = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Workout summary will be shown.")
            }
        }
    }

    // MARK: - Helper Methods

    /// Calculate Y position based on bar position setting
    private func calculateYPosition(for screenHeight: CGFloat) -> CGFloat {
        let barHeight: CGFloat = 70 // Compact bar height
        let safeAreaTop: CGFloat = 50 // Safe area top
        let safeAreaBottom: CGFloat = 60 // Tab bar height (~50pt) + padding

        switch manager.barPosition {
        case .top:
            return safeAreaTop
        case .middle:
            return (screenHeight - barHeight) / 2
        case .bottom:
            return screenHeight - barHeight - safeAreaBottom
        }
    }

    /// Snap to nearest position based on drag height
    private func snapToNearestPosition(dragHeight: CGFloat, screenHeight: CGFloat) {
        let currentY = calculateYPosition(for: screenHeight) + dragHeight
        let topY = calculateYPosition(for: screenHeight, position: .top)
        let middleY = calculateYPosition(for: screenHeight, position: .middle)
        let bottomY = calculateYPosition(for: screenHeight, position: .bottom)

        // Calculate distances to each position
        let distanceToTop = abs(currentY - topY)
        let distanceToMiddle = abs(currentY - middleY)
        let distanceToBottom = abs(currentY - bottomY)

        // Find closest position
        let minDistance = min(distanceToTop, distanceToMiddle, distanceToBottom)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if minDistance == distanceToTop {
                manager.barPosition = .top
            } else if minDistance == distanceToMiddle {
                manager.barPosition = .middle
            } else {
                manager.barPosition = .bottom
            }
            dragOffset = 0

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    /// Calculate Y position for a specific position
    private func calculateYPosition(for screenHeight: CGFloat, position: WorkoutBarPosition) -> CGFloat {
        let barHeight: CGFloat = 70 // Compact bar height
        let safeAreaTop: CGFloat = 50
        let safeAreaBottom: CGFloat = 80

        switch position {
        case .top:
            return safeAreaTop
        case .middle:
            return (screenHeight - barHeight) / 2
        case .bottom:
            return screenHeight - barHeight - safeAreaBottom
        }
    }
}

// MARK: - Preview

#Preview {
    let manager = ActiveWorkoutManager()
    let deps = AppDependencies.preview

    let workout = Workout(date: Date(), type: .lifting)
    let viewModel = LiftingSessionViewModel(
        workoutRepository: deps.workoutRepository,
        exerciseRepository: deps.exerciseRepository,
        prDetectionService: deps.prDetectionService
    )

    // Mock data
    let exercise = Exercise(
        name: "Barbell Squat",
        category: .barbell,
        muscleGroups: [.quads],
        equipment: .barbell,
        isCustom: false,
        version: 1
    )
    let workoutExercise = WorkoutExercise(exercise: exercise, orderIndex: 0)
    workoutExercise.sets = [
        WorkoutSet(reps: 10, weight: 100, isCompleted: true),
        WorkoutSet(reps: 10, weight: 100, isCompleted: true),
        WorkoutSet(reps: 10, weight: 100, isCompleted: false)
    ]
    viewModel.exercises.append(workoutExercise)

    manager.startWorkout(workout: workout, viewModel: viewModel)
    manager.minimizeWorkout()

    return VStack {
        Spacer()
        ActiveWorkoutBar(manager: manager)
    }
    .background(DSColors.backgroundPrimary)
}
