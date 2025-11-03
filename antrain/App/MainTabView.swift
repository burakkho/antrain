import SwiftUI

/// Main tab bar navigation
/// 4 tabs: Home, Workouts, Nutrition, Settings
struct MainTabView: View {
    @State private var selectedTab = 0
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
        .preferredColorScheme(colorScheme)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNutritionTab"))) { _ in
            selectedTab = 2
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
