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
    // Use PersistenceController for centralized ModelContainer management
    @MainActor
    private let persistenceController = PersistenceController.shared

    // App language preference
    @AppStorage("appLanguage") private var appLanguage: String = "en"

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
        }
        .modelContainer(persistenceController.modelContainer)
    }
}
