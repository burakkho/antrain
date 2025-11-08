//
//  WidgetDataHelper.swift
//  antrain
//
//  Widget Data Sharing Helper
//  Simple UserDefaults-based data sharing between app and widget
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Helper for sharing workout stats with widget
/// Uses UserDefaults (simple approach without App Group)
final class WidgetDataHelper {
    static let shared = WidgetDataHelper()
    
    private let defaults = UserDefaults.standard
    private let workoutCountKey = "widget_workout_count"
    private let lastWorkoutDateKey = "widget_last_workout_date"
    private let activeProgramKey = "widget_active_program"
    
    private init() {}
    
    // MARK: - Write Data (App → Widget)
    
    /// Update workout count for widget
    func updateWorkoutCount(_ count: Int) {
        defaults.set(count, forKey: workoutCountKey)
    }
    
    /// Update last workout date
    func updateLastWorkoutDate(_ date: Date) {
        defaults.set(date, forKey: lastWorkoutDateKey)
    }
    
    /// Update active program name
    func updateActiveProgram(_ programName: String?) {
        defaults.set(programName, forKey: activeProgramKey)
    }
    
    /// Update all widget data at once
    func updateWidgetData(workoutCount: Int, lastWorkoutDate: Date?, activeProgram: String?) {
        updateWorkoutCount(workoutCount)
        if let date = lastWorkoutDate {
            updateLastWorkoutDate(date)
        }
        updateActiveProgram(activeProgram)
        
        // Refresh widget
        refreshWidget()
    }
    
    // MARK: - Read Data (Widget → Display)
    
    /// Get this week's workout count
    func getWorkoutCount() -> Int {
        return defaults.integer(forKey: workoutCountKey)
    }
    
    /// Get last workout date
    func getLastWorkoutDate() -> Date? {
        return defaults.object(forKey: lastWorkoutDateKey) as? Date
    }
    
    /// Get active program name
    func getActiveProgram() -> String? {
        return defaults.string(forKey: activeProgramKey)
    }
    
    // MARK: - Widget Refresh
    
    /// Tell widget to refresh its data
    private func refreshWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
