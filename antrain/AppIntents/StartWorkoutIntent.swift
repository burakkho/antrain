//
//  StartWorkoutIntent.swift
//  antrain
//
//  App Intent for starting a workout via Siri
//  "Hey Siri, start workout"
//

import AppIntents
import Foundation
import UIKit

/// Intent to start a new workout
/// Supports Siri, Shortcuts, and Spotlight
struct StartWorkoutIntent: AppIntent {
    // MARK: - Intent Metadata
    
    /// Localized title shown in Shortcuts app
    nonisolated(unsafe) static var title: LocalizedStringResource = "Start Workout"
    
    /// Description shown in Shortcuts app
    static var description: IntentDescription {
        IntentDescription("Begin your workout session")
    }
    
    /// Parameterless summary
    static var parameterSummary: some ParameterSummary {
        Summary("Start a workout")
    }
    
    /// Icon shown in Shortcuts app
    nonisolated(unsafe) static var openAppWhenRun: Bool = true
    
    // MARK: - Perform Action
    
    /// Execute the intent
    func perform() async throws -> some IntentResult {
        // Simply return success - app will open automatically via openAppWhenRun
        return .result()
    }
}

// MARK: - App Shortcuts Provider

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWorkoutIntent(),
            phrases: [
                // English
                "Start workout in \(.applicationName)",
                "Begin workout in \(.applicationName)",
                "Start my workout in \(.applicationName)",
                
                // Turkish
                "\(.applicationName) antrenmana başla",
                "\(.applicationName) ile antrenmana başla"
            ],
            shortTitle: "Start Workout",
            systemImageName: "dumbbell.fill"
        )
    }
}
