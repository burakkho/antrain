import SwiftUI

/// Main tab bar navigation
/// Displays 4 tabs: Home, AI Coach, Nutrition, Workouts
///
/// Refactored for Clean Architecture:
/// - AppCoordinator: Deep link handling
/// - MainTabViewModel: Lifecycle management
/// - ViewModifiers: Reusable behaviors (theme, workout overlay)
struct MainTabView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var viewModel: MainTabViewModel?
    @State private var coordinator: AppCoordinator
    @State private var workoutManager: ActiveWorkoutManager
    @State private var showOnboarding = false
    @State private var isCheckingOnboarding = true

    init() {
        let workoutManager = ActiveWorkoutManager()
        let coordinator = AppCoordinator(workoutManager: workoutManager)

        _workoutManager = State(initialValue: workoutManager)
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        mainTabView
            .themedColorScheme()
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingWizardView(
                    userProfileRepository: appDependencies.userProfileRepository,
                    onComplete: {
                        showOnboarding = false
                        // Navigate to Home tab after onboarding
                        coordinator.selectedTab = 0
                    }
                )
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

            AICoachView()
                .tabItem {
                    Label("AI Coach", systemImage: "brain.head.profile")
                }
                .tag(1)

            DailyNutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(2)

            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
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

            // Check onboarding status
            await checkOnboardingStatus()

            // Perform one-time initialization
            await viewModel?.onAppear()
        }
    }

    // MARK: - Onboarding Check

    private func checkOnboardingStatus() async {
        do {
            let profile = try await appDependencies.userProfileRepository.fetchOrCreateProfile()

            // Show onboarding if user hasn't completed it
            if !profile.hasCompletedInitialOnboarding {
                showOnboarding = true
            }

            isCheckingOnboarding = false
        } catch {
            print("❌ [MainTabView] Error checking onboarding status: \(error)")
            isCheckingOnboarding = false
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppDependencies.preview)
}
