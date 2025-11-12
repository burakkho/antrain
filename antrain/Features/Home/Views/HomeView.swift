import SwiftUI

/// Home screen with quick actions and recent workouts
struct HomeView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @Environment(ActiveWorkoutManager.self) private var workoutManager
    @State private var viewModel: HomeViewModel?
    @State private var showCardioLog = false
    @State private var showMetConLog = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {                
                // Profile Summary Card
                    if let viewModel {
                        profileSummarySection(viewModel: viewModel)
                    }

                    // Quick Actions
                    quickActionsSection

                    // Today's Nutrition
                    if let viewModel {
                        nutritionSummarySection(viewModel: viewModel)
                    }

                    // Personal Records (Workout Summary)
                    DailyWorkoutSummary(limit: 5)

                    // Recent Workouts
                    if let viewModel {
                        recentWorkoutsSection(viewModel: viewModel)
                    }
                }
                .padding(DSSpacing.md)
            }
            .navigationTitle(Text("Home"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(DSColors.textSecondary)
                    }
                }
            }
            .background(DSColors.backgroundPrimary)
            .refreshable {
                await viewModel?.loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WorkoutSaved"))) { _ in
                Task {
                    await viewModel?.loadRecentWorkouts()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NutritionUpdated"))) { _ in
                Task {
                    await viewModel?.loadTodayNutrition()
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = HomeViewModel(
                        workoutRepository: appDependencies.workoutRepository,
                        nutritionRepository: appDependencies.nutritionRepository,
                        userProfileRepository: appDependencies.userProfileRepository
                    )
                    Task {
                        await viewModel?.loadData()
                    }
                }
            }
            .sheet(isPresented: $showCardioLog) {
                CardioLogView()
                    .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showMetConLog) {
                MetConLogView()
                    .environmentObject(appDependencies)
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Profile Summary Section

    private func profileSummarySection(viewModel: HomeViewModel) -> some View {
        Group {
            if let profile = viewModel.userProfile {
                NavigationLink {
                    ProfileView()
                } label: {
                    HomeProfileCard(profile: profile) {
                        // onTap action, if any specific action is needed beyond navigation
                    }
                }
                .buttonStyle(PlainButtonStyle()) // To remove default NavigationLink styling
            }
        }
    }


    // MARK: - Nutrition Summary Section

    private func nutritionSummarySection(viewModel: HomeViewModel) -> some View {
        Group {
            if let nutritionLog = viewModel.todayNutritionLog,
               let profile = viewModel.userProfile {
                CompactNutritionSummary(
                    calories: nutritionLog.totalCalories,
                    calorieGoal: profile.dailyCalorieGoal,
                    protein: nutritionLog.totalProtein,
                    proteinGoal: profile.dailyProteinGoal,
                    carbs: nutritionLog.totalCarbs,
                    carbsGoal: profile.dailyCarbsGoal,
                    fats: nutritionLog.totalFats,
                    fatsGoal: profile.dailyFatsGoal,
                    onTap: {
                        // Switch to Nutrition tab
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToNutritionTab"), object: nil)
                    }
                )
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Quick Actions")
                .font(DSTypography.title3)
                .foregroundStyle(DSColors.textPrimary)

            HStack(spacing: DSSpacing.sm) {
                QuickActionButton(
                    icon: "dumbbell.fill",
                    title: "Start Workout",
                    action: {
                        workoutManager.showFullScreen = true
                    }
                )

                QuickActionButton(
                    icon: "figure.run",
                    title: "Log Cardio",
                    action: { showCardioLog = true }
                )

                QuickActionButton(
                    icon: "flame.fill",
                    title: "Log MetCon",
                    action: { showMetConLog = true }
                )
            }
        }
    }

    // MARK: - Recent Workouts Section

    private func recentWorkoutsSection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Recent Workouts")
                .font(DSTypography.title3)
                .foregroundStyle(DSColors.textPrimary)

            if viewModel.isLoading {
                DSLoadingView(message: "Loading workouts...")
                    .frame(height: 200)
            } else if let errorMessage = viewModel.errorMessage {
                DSErrorView(
                    errorMessage: LocalizedStringKey(errorMessage),
                    retryAction: {
                        Task {
                            await viewModel.loadRecentWorkouts()
                        }
                    }
                )
                .frame(height: 200)
            } else if viewModel.recentWorkouts.isEmpty {
                DSEmptyState(
                    icon: "dumbbell",
                    title: "No Workouts Yet",
                    message: "Start your first workout to see it here!",
                    actionTitle: "Start Workout",
                    action: { workoutManager.showFullScreen = true }
                )
                .frame(height: 300)
            } else {
                VStack(spacing: DSSpacing.sm) {
                    ForEach(viewModel.recentWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            RecentWorkoutRow(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Home - Light Mode") {
    @Previewable @State var workoutManager = ActiveWorkoutManager()
    
    NavigationStack {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Quick Actions Preview
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Quick Actions")
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColors.textPrimary)
                    
                    HStack(spacing: DSSpacing.md) {
                        QuickActionButton(
                            icon: "dumbbell.fill",
                            title: "Start Workout"
                        ) {}
                        
                        QuickActionButton(
                            icon: "figure.run",
                            title: "Log Cardio"
                        ) {}
                        
                        QuickActionButton(
                            icon: "fork.knife",
                            title: "Log Meal"
                        ) {}
                    }
                }
                
                // Nutrition Preview
                CompactNutritionSummary(
                    calories: 1450,
                    calorieGoal: 2000,
                    protein: 85,
                    proteinGoal: 150,
                    carbs: 150,
                    carbsGoal: 200,
                    fats: 45,
                    fatsGoal: 65,
                    onTap: {}
                )
                
                // Workout Preview
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Recent Workouts")
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColors.textPrimary)
                    
                    RecentWorkoutRow(
                        workout: Workout(date: Date(), type: .lifting)
                    )
                    
                    RecentWorkoutRow(
                        workout: Workout(date: Date().addingTimeInterval(-86400), type: .cardio)
                    )
                }
            }
            .padding(DSSpacing.md)
        }
        .navigationTitle(Text("Home"))
        .background(DSColors.backgroundPrimary)
    }
}

#Preview("Home - Dark Mode") {
    @Previewable @State var workoutManager = ActiveWorkoutManager()
    
    NavigationStack {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Quick Actions
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Quick Actions")
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColors.textPrimary)
                    
                    HStack(spacing: DSSpacing.md) {
                        QuickActionButton(
                            icon: "dumbbell.fill",
                            title: "Start Workout"
                        ) {}
                        
                        QuickActionButton(
                            icon: "figure.run",
                            title: "Log Cardio"
                        ) {}
                        
                        QuickActionButton(
                            icon: "fork.knife",
                            title: "Log Meal"
                        ) {}
                    }
                }
                
                // Nutrition
                CompactNutritionSummary(
                    calories: 1800,
                    calorieGoal: 2000,
                    protein: 120,
                    proteinGoal: 150,
                    carbs: 180,
                    carbsGoal: 200,
                    fats: 55,
                    fatsGoal: 65,
                    onTap: {}
                )
                
                // Workouts
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Recent Workouts")
                        .font(DSTypography.title3)
                        .foregroundStyle(DSColors.textPrimary)
                    
                    RecentWorkoutRow(
                        workout: Workout(date: Date(), type: .lifting)
                    )
                }
            }
            .padding(DSSpacing.md)
        }
        .navigationTitle(Text("Home"))
        .background(DSColors.backgroundPrimary)
    }
    .preferredColorScheme(.dark)
}
