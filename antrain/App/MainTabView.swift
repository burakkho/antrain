import SwiftUI

/// Main tab bar navigation
/// 4 tabs: Home, Workouts, Nutrition, Settings
struct MainTabView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var selectedTab = 0
    @State private var workoutManager = ActiveWorkoutManager()
    @AppStorage("appTheme") private var appTheme: String = "system"
    @State private var isSeeding = false
    @State private var seedingProgress = ""

    var body: some View {
        Group {
            if isSeeding {
                seedingView
            } else {
                mainTabView
            }
        }
        .preferredColorScheme(colorScheme)
        .task {
            // Monitor seeding status
            await monitorSeeding()
        }
    }

    // MARK: - Seeding View

    private var seedingView: some View {
        VStack(spacing: 24) {
            Spacer()

            // App logo or icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accent)

            Text("antrain")
                .font(.system(size: 32, weight: .bold))

            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 8)

            Text(seedingProgress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Text("Setting up your workout library...")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
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
                existingViewModel: workoutManager.activeViewModel,
                initialTemplate: workoutManager.pendingTemplate,
                programDay: workoutManager.pendingProgramDay
            )
            .environmentObject(appDependencies)
        }
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToWorkoutsCalendar"))) { _ in
            selectedTab = 1
        }
        .onAppear {
            // Silently restore active workout session if exists
            Task {
                await workoutManager.restoreState(
                    workoutRepository: appDependencies.workoutRepository,
                    exerciseRepository: appDependencies.exerciseRepository,
                    prDetectionService: appDependencies.prDetectionService,
                    progressiveOverloadService: appDependencies.progressiveOverloadService,
                    userProfileRepository: appDependencies.userProfileRepository
                )
            }
        }
    }

    // MARK: - Seeding Monitor

    private func monitorSeeding() async {
        let controller = PersistenceController.shared

        // Poll seeding status
        while await controller.isSeeding {
            await MainActor.run {
                isSeeding = true
                seedingProgress = controller.seedingProgress
            }
            try? await Task.sleep(for: .milliseconds(100))
        }

        // Seeding complete
        await MainActor.run {
            isSeeding = false
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
