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
        // Register notification categories (synchronous, no main thread blocking)
        NotificationService.shared.registerCategories()

        // Apple Best Practice: Don't check notification status eagerly at app launch
        // Status will be checked lazily in MainTabView.task after UI renders
    }
    // Use PersistenceController for centralized ModelContainer management
    @MainActor
    private let persistenceController = PersistenceController.shared

    // App language preference
    @AppStorage("appLanguage") private var appLanguage: String = "en"

    // Scene phase for notification scheduling
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(AppDependencies.shared)
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
                // App became active, re-schedule notifications in background
                Task {
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
