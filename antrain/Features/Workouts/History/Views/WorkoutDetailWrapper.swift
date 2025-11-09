import SwiftUI

/// Wrapper view to load workout by ID and display WorkoutDetailView
struct WorkoutDetailWrapper: View {
    let workoutId: UUID
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var workout: Workout?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                DSLoadingView(message: "Loading workout...")
            } else if let errorMessage {
                DSErrorView(
                    errorMessage: LocalizedStringKey(errorMessage),
                    retryAction: {
                        Task {
                            await loadWorkout()
                        }
                    }
                )
            } else if let workout {
                WorkoutDetailView(workout: workout)
            } else {
                DSEmptyState(
                    icon: "exclamationmark.triangle",
                    title: "Workout Not Found",
                    message: "This workout may have been deleted."
                )
            }
        }
        .onAppear {
            if workout == nil {
                Task {
                    await loadWorkout()
                }
            }
        }
    }

    // MARK: - Load Workout

    private func loadWorkout() async {
        isLoading = true
        errorMessage = nil

        do {
            workout = try await appDependencies.workoutRepository.fetch(id: workoutId)
            isLoading = false
        } catch {
            errorMessage = "Failed to load workout"
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WorkoutDetailWrapper(workoutId: UUID())
            .environmentObject(AppDependencies.preview)
    }
}
