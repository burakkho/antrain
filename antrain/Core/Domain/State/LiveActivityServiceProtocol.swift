//
//  LiveActivityServiceProtocol.swift
//  antrain
//
//  Protocol for Live Activity service
//  Allows dependency injection and testing
//

import Foundation

/// Protocol for managing workout Live Activities
@MainActor
protocol LiveActivityServiceProtocol {
    /// Start a new workout Live Activity
    func startActivity(workoutName: String)
    
    /// Update the Live Activity with current workout state
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
    )
    
    /// End the current Live Activity
    func endActivity()
}
