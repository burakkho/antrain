//
//  antrainApp.swift
//  antrain
//
//  Created by Burak Macbook Mini on 2.11.2025.
//  Updated by Claude Code on 2025-02-11.
//

import SwiftUI
import SwiftData

@main
struct antrainApp: App {
    
    init() {
        // Register notification categories
        NotificationService.shared.registerCategories()

        // Initial notification status check and scheduling
        Task { @MainActor in
            await NotificationService.shared.updateAuthorizationStatus()
            await NotificationService.shared.scheduleNextNotification()
        }
    }
    // Use PersistenceController for centralized ModelContainer management
    @MainActor
    private let persistenceController = PersistenceController.shared

    // App language preference
    @AppStorage("appLanguage") private var appLanguage: String = "en"

    // Scene phase for notification scheduling
    @Environment(\.scenePhase) private var scenePhase

    // Dependency injection container
    @MainActor
    private var dependencies: AppDependencies {
        AppDependencies(modelContainer: persistenceController.modelContainer)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dependencies)
                .environment(\.locale, .init(identifier: appLanguage))
                .onOpenURL { url in
                    handleURLOpen(url)
                }
                .onReceive(NotificationCenter.default.publisher(
                    for: NSNotification.Name("StartWorkoutFromNotification")
                )) { notification in
                    // Handle deep link to workout
                    handleWorkoutDeepLink(notification.userInfo)
                }
        }
        .modelContainer(persistenceController.modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // App became active, check if we need to re-schedule
                Task { @MainActor in
                    await NotificationService.shared.scheduleNextNotification()
                }
            }
        }
    }

    // MARK: - Deep Linking

    private func handleURLOpen(_ url: URL) {
        guard url.scheme == "antrain" else { return }
        
        switch url.host {
        case "start-workout":
            // Post notification to navigate to workout
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToWorkout"),
                object: nil
            )
        default:
            break
        }
    }

    private func handleWorkoutDeepLink(_ userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo else { return }

        // Post to app-wide notification for navigation
        // NOTE: Phase 7 - Actual navigation implementation
        // For now, just log the deep link attempt
        print("Deep link to start workout: \(userInfo)")

        // Future implementation:
        // NotificationCenter.default.post(
        //     name: NSNotification.Name("NavigateToWorkout"),
        //     object: userInfo["workoutName"]
        // )
    }
}
