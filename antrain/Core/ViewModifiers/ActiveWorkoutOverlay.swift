//
//  ActiveWorkoutOverlay.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//

import SwiftUI

/// ViewModifier that adds active workout overlay and fullscreen presentation
/// Encapsulates workout bar positioning and tab switching behavior
/// Extracted from MainTabView for reusability and better code organization
struct ActiveWorkoutOverlay: ViewModifier {
    @Bindable var workoutManager: ActiveWorkoutManager
    @Binding var selectedTab: Int
    let appDependencies: AppDependencies

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                // Show mini workout bar at bottom when workout is active but minimized
                if workoutManager.isActive && !workoutManager.showFullScreen {
                    ActiveWorkoutBar(manager: workoutManager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .fullScreenCover(isPresented: $workoutManager.showFullScreen) {
                // Full screen workout view
                LiftingSessionView(
                    workoutManager: workoutManager,
                    existingViewModel: workoutManager.activeViewModel,
                    initialTemplate: workoutManager.pendingTemplate,
                    programDay: workoutManager.pendingProgramDay
                )
                .environmentObject(appDependencies)
            }
            .onChange(of: selectedTab) { _, _ in
                minimizeWorkoutOnTabSwitch()
            }
    }

    // MARK: - Tab Switching Logic

    /// Minimize workout when user switches tabs
    /// Returns to home tab to show workout bar
    private func minimizeWorkoutOnTabSwitch() {
        guard workoutManager.isActive && workoutManager.showFullScreen else { return }

        withAnimation(.spring(response: 0.3)) {
            workoutManager.minimizeWorkout()
            selectedTab = 0  // Return to home
        }
    }
}

// MARK: - View Extension

extension View {
    /// Adds active workout overlay and fullscreen presentation behavior
    /// - Parameters:
    ///   - workoutManager: ActiveWorkoutManager instance
    ///   - selectedTab: Binding to current tab selection
    ///   - appDependencies: App dependencies for workout view
    /// - Returns: View with workout overlay modifier applied
    func activeWorkoutOverlay(
        workoutManager: ActiveWorkoutManager,
        selectedTab: Binding<Int>,
        appDependencies: AppDependencies
    ) -> some View {
        modifier(ActiveWorkoutOverlay(
            workoutManager: workoutManager,
            selectedTab: selectedTab,
            appDependencies: appDependencies
        ))
    }
}
