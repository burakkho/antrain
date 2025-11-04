import SwiftUI

/// Home screen with quick actions and recent workouts
struct HomeView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var viewModel: HomeViewModel?
    @State private var showLiftingSession = false
    @State private var showCardioLog = false
    @State private var showMetConLog = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    // Welcome Message
                    if let viewModel {
                        welcomeSection(viewModel: viewModel)
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
            .navigationTitle("Home")
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
            .fullScreenCover(isPresented: $showLiftingSession) {
                LiftingSessionView()
                    .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showCardioLog) {
                CardioLogView()
                    .environmentObject(appDependencies)
            }
            .sheet(isPresented: $showMetConLog) {
                MetConLogView()
                    .environmentObject(appDependencies)
            }
        }
    }

    // MARK: - Welcome Section

    private func welcomeSection(viewModel: HomeViewModel) -> some View {
        HStack {
            if let profile = viewModel.userProfile, !profile.name.isEmpty {
                Text("\(greetingMessage), ")
                    .font(DSTypography.title1)
                    .foregroundStyle(DSColors.textPrimary)
                +
                Text(profile.name)
                    .font(DSTypography.title1)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColors.primary)
            } else {
                Text(greetingMessage)
                    .font(DSTypography.title1)
                    .foregroundStyle(DSColors.textPrimary)
            }

            Spacer()
        }
    }

    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return String(localized: "Good Morning")
        case 12..<18:
            return String(localized: "Hello")
        case 18..<22:
            return String(localized: "Good Evening")
        default:
            return String(localized: "Hello")
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
                    action: { showLiftingSession = true }
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
                    action: { showLiftingSession = true }
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

#Preview {
    HomeView()
        .environmentObject(AppDependencies.preview)
}
