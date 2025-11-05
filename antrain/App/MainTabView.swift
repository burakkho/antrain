import SwiftUI

/// Main tab bar navigation
/// 4 tabs: Home, Workouts, Nutrition, Settings
struct MainTabView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var selectedTab = 0
    @State private var workoutManager = ActiveWorkoutManager()
    @AppStorage("appTheme") private var appTheme: String = "system"

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
                .tag(1)

            DailyNutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .environment(workoutManager)
        .overlay(alignment: .bottom) {
            if workoutManager.isActive && !workoutManager.showFullScreen {
                ActiveWorkoutBar(manager: workoutManager)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $workoutManager.showFullScreen) {
            LiftingSessionView(
                workoutManager: workoutManager,
                existingViewModel: workoutManager.activeViewModel
            )
            .environmentObject(appDependencies)
        }
        .preferredColorScheme(colorScheme)
        .onChange(of: selectedTab) { _, _ in
            // Minimize workout when switching tabs
            if workoutManager.isActive && workoutManager.showFullScreen {
                withAnimation(.spring(response: 0.3)) {
                    workoutManager.minimizeWorkout()
                    selectedTab = 0  // Return to home
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNutritionTab"))) { _ in
            selectedTab = 2
        }
        .onAppear {
            // Silently restore active workout session if exists
            Task {
                await workoutManager.restoreState(
                    workoutRepository: appDependencies.workoutRepository,
                    exerciseRepository: appDependencies.exerciseRepository,
                    prDetectionService: appDependencies.prDetectionService
                )
            }
        }
    }

    // MARK: - Theme Support

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil  // System default
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppDependencies.preview)
}
