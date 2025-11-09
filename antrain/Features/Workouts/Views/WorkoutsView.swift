import SwiftUI

/// Main workouts view with segmented control navigation
struct WorkoutsView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var selectedSection: WorkoutSection = .overview
    @State private var overviewViewMode: HistoryViewMode = .list

    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("Section", selection: $selectedSection) {
                Text("Overview").tag(WorkoutSection.overview)
                Text("Templates").tag(WorkoutSection.templates)
                Text("Programs").tag(WorkoutSection.programs)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)

            // Content based on selection
            Group {
                switch selectedSection {
                case .overview:
                    WorkoutsOverviewView(viewMode: $overviewViewMode)
                        .environmentObject(appDependencies)
                case .templates:
                    WorkoutTemplatesView()
                        .environmentObject(appDependencies)
                case .programs:
                    WorkoutProgramsView()
                        .environmentObject(appDependencies)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToProgramsTab"))) { _ in
            selectedSection = .programs
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToWorkoutsCalendar"))) { _ in
            selectedSection = .overview
            overviewViewMode = .calendar
        }
    }
}

// MARK: - Supporting Types

enum WorkoutSection {
    case overview
    case templates
    case programs
}

enum WorkoutTypeFilter: String, CaseIterable {
    case all = "All"
    case lifting = "Lifting"
    case cardio = "Cardio"
    case metcon = "MetCon"
}

// MARK: - Preview

#Preview {
    @Previewable @State var workoutManager = ActiveWorkoutManager()

    WorkoutsView()
        .environmentObject(AppDependencies.preview)
        .environment(workoutManager)
}
