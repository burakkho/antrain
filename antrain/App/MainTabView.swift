import SwiftUI

/// Main tab bar navigation
/// Displays 4 tabs: Home, Workouts, Nutrition, Profile
///
/// Refactored for Clean Architecture:
/// - SeedingView: Extracted loading screen
/// - AppCoordinator: Deep link handling
/// - MainTabViewModel: Lifecycle management
/// - ViewModifiers: Reusable behaviors (theme, workout overlay)
struct MainTabView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var viewModel: MainTabViewModel?
    @State private var seedingViewModel: SeedingViewModel
    @State private var coordinator: AppCoordinator
    @State private var workoutManager: ActiveWorkoutManager

    init() {
        let workoutManager = ActiveWorkoutManager()
        let coordinator = AppCoordinator(workoutManager: workoutManager)

        _workoutManager = State(initialValue: workoutManager)
        _coordinator = State(initialValue: coordinator)
        _seedingViewModel = State(initialValue: SeedingViewModel())
    }

    var body: some View {
        Group {
            if seedingViewModel.isSeeding {
                SeedingView(viewModel: seedingViewModel)
            } else {
                mainTabView
            }
        }
        .themedColorScheme()
        .task {
            // Monitor seeding progress
            await seedingViewModel.startMonitoring()
        }
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        TabView(selection: $coordinator.selectedTab) {
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

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .environment(workoutManager)
        .activeWorkoutOverlay(
            workoutManager: workoutManager,
            selectedTab: $coordinator.selectedTab,
            appDependencies: appDependencies
        )
        .task {
            // Initialize ViewModel with app dependencies (available after EnvironmentObject injection)
            if viewModel == nil {
                viewModel = MainTabViewModel(
                    appDependencies: appDependencies,
                    workoutManager: workoutManager,
                    coordinator: coordinator
                )
            }

            // Perform one-time initialization
            await viewModel?.onAppear()
        }
    }

}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppDependencies.preview)
}
