//
//  WorkoutActivityAttributes.swift
//  antrain
//
//  Live Activity attributes for workout tracking
//  Shared between app and widget extension
//

import ActivityKit
import Foundation

/// Attributes for workout Live Activity
/// These define the unchanging data for the activity's lifetime
struct WorkoutActivityAttributes: ActivityAttributes {
    /// Dynamic state that updates during the workout
    public struct ContentState: Codable, Hashable {
        // Current exercise info
        var currentExerciseName: String
        var currentSetNumber: Int
        var totalSets: Int
        
        // Current set details
        var currentWeight: Double
        var currentReps: Int
        
        // Rest timer (Phase 2 - currently disabled)
        // TODO: Implement proper rest timer with background handling
        var isResting: Bool
        var restTimeRemaining: Int // seconds
        
        // Workout summary
        var completedSets: Int
        var totalVolume: Double // kg
        var exerciseCount: Int

        // Note: Duration removed - Widget now calculates it automatically
        // using startTime from WorkoutActivityAttributes via Text(timerInterval:)
    }
    
    // Static attributes (don't change during activity)
    var workoutName: String
    var startTime: Date
}
