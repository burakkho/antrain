//
//  AntrainWidgetLiveActivity.swift
//  AntrainWidget
//
//  Live Activity widget for workout tracking
//  Displays workout progress on Lock Screen and Dynamic Island
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AntrainWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI - shows when user long-presses
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 5) {
                        Label {
                            Text(context.attributes.workoutName)
                                .font(.caption2)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "figure.strengthtraining.traditional")
                        }
                        .foregroundStyle(.secondary)
                        
                        Text(context.state.currentExerciseName)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Set \(context.state.currentSetNumber)/\(context.state.totalSets)")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text("\(Int(context.state.currentWeight))kg × \(context.state.currentReps)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        // Duration
                        VStack(spacing: 2) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text(formatDuration(context.state.duration))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        // Volume
                        VStack(spacing: 2) {
                            Image(systemName: "scalemass.fill")
                                .font(.caption2)
                            Text("\(Int(context.state.totalVolume))kg")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        // Sets completed
                        VStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                            Text("\(context.state.completedSets) sets")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        // TODO: Rest Timer - Phase 2
                        // Disabled for now due to performance concerns
                        // Will implement with proper background timer handling
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                // Compact leading - left side of Dynamic Island
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                // Compact trailing - right side of Dynamic Island
                // Show current set progress
                Text("\(context.state.currentSetNumber)/\(context.state.totalSets)")
                    .font(.caption2)
                    .fontWeight(.bold)
            } minimal: {
                // Minimal - when multiple activities are active
                // Show workout icon
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.orange)
            }
            .keylineTint(.orange)
        }
    }
    
    // Helper function to format duration
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title3)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.workoutName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(context.state.currentExerciseName)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text(formatDuration(context.state.duration))
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            
            // Current Set Info
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SET")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(context.state.currentSetNumber) / \(context.state.totalSets)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("WEIGHT × REPS")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(context.state.currentWeight))kg × \(context.state.currentReps)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            // Workout Stats
            HStack(spacing: 16) {
                StatView(
                    icon: "dumbbell.fill",
                    title: "Exercises",
                    value: "\(context.state.exerciseCount)"
                )
                
                StatView(
                    icon: "checkmark.circle.fill",
                    title: "Sets",
                    value: "\(context.state.completedSets)"
                )
                
                StatView(
                    icon: "scalemass.fill",
                    title: "Volume",
                    value: "\(Int(context.state.totalVolume))kg"
                )
            }
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.3))
        .activitySystemActionForegroundColor(Color.white)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Stat View Component

struct StatView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.orange)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

extension WorkoutActivityAttributes {
    fileprivate static var preview: WorkoutActivityAttributes {
        WorkoutActivityAttributes(
            workoutName: "Push Day",
            startTime: Date()
        )
    }
}

extension WorkoutActivityAttributes.ContentState {
    fileprivate static var activeSet: WorkoutActivityAttributes.ContentState {
        WorkoutActivityAttributes.ContentState(
            currentExerciseName: "Bench Press",
            currentSetNumber: 3,
            totalSets: 4,
            currentWeight: 80,
            currentReps: 8,
            isResting: false,
            restTimeRemaining: 0,
            completedSets: 12,
            totalVolume: 2400,
            duration: 1245,
            exerciseCount: 3
        )
    }
    
    // TODO: Resting state preview - disabled until Phase 2
    /*
    fileprivate static var resting: WorkoutActivityAttributes.ContentState {
        WorkoutActivityAttributes.ContentState(
            currentExerciseName: "Bench Press",
            currentSetNumber: 3,
            totalSets: 4,
            currentWeight: 80,
            currentReps: 8,
            isResting: true,
            restTimeRemaining: 45,
            completedSets: 12,
            totalVolume: 2400,
            duration: 1245,
            exerciseCount: 3
        )
    }
    */
}

#Preview("Notification", as: .content, using: WorkoutActivityAttributes.preview) {
   AntrainWidgetLiveActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.activeSet
}
