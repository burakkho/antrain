//
//  LiveActivityService.swift
//  antrain
//
//  Concrete implementation of Live Activity service
//  Uses ActivityKit framework
//

import ActivityKit
import Foundation

/// Service for managing workout Live Activities
@MainActor
final class LiveActivityService: LiveActivityServiceProtocol {
    
    // Current active activity
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    
    // MARK: - Start Activity
    
    func startActivity(workoutName: String) {
        // Check iOS version
        guard #available(iOS 18.2, *) else {
            print("⚠️ Live Activities require iOS 18.2+")
            return
        }
        
        // Check if Live Activities are available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities not enabled")
            return
        }
        
        // End any existing activity first
        endActivity()
        
        // Create initial state
        let initialState = WorkoutActivityAttributes.ContentState(
            currentExerciseName: "Starting...",
            currentSetNumber: 0,
            totalSets: 0,
            currentWeight: 0,
            currentReps: 0,
            isResting: false,
            restTimeRemaining: 0,
            completedSets: 0,
            totalVolume: 0,
            duration: 0,
            exerciseCount: 0
        )
        
        // Create attributes
        let attributes = WorkoutActivityAttributes(
            workoutName: workoutName,
            startTime: Date()
        )
        
        do {
            // Start the activity
            let activity = try Activity<WorkoutActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }
    
    // MARK: - Update Activity
    
    func updateActivity(
        currentExerciseName: String,
        currentSetNumber: Int,
        totalSets: Int,
        currentWeight: Double,
        currentReps: Int,
        isResting: Bool,
        restTimeRemaining: Int,
        completedSets: Int,
        totalVolume: Double,
        duration: TimeInterval,
        exerciseCount: Int
    ) {
        guard let activity = currentActivity else {
            print("⚠️ No active Live Activity to update")
            return
        }
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            currentExerciseName: currentExerciseName,
            currentSetNumber: currentSetNumber,
            totalSets: totalSets,
            currentWeight: currentWeight,
            currentReps: currentReps,
            isResting: isResting,
            restTimeRemaining: restTimeRemaining,
            completedSets: completedSets,
            totalVolume: totalVolume,
            duration: duration,
            exerciseCount: exerciseCount
        )
        
        Task {
            // Using deprecated API - newer API has different signature that doesn't work for our use case
            await activity.update(using: updatedState)
            print("✅ Live Activity updated")
        }
    }
    
    // MARK: - End Activity

    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            // Using deprecated API - newer API has different signature that doesn't work for our use case
            await activity.end(
                using: activity.content.state,
                dismissalPolicy: .default
            )
            currentActivity = nil
            print("✅ Live Activity ended")
        }
    }
}
