//
//  CSVExportService.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Export workouts to CSV format (Hevy/Strong compatible)
//

import Foundation

/// Service for exporting workouts to CSV format (compatible with Hevy, Strong, Fitbod)
class CSVExportService {
    // MARK: - Public API

    /// Export workouts to CSV format
    /// - Parameter workouts: Workouts to export
    /// - Returns: CSV content as String
    func exportWorkouts(_ workouts: [Workout]) -> String {
        var csvContent = csvHeader()

        // Flatten workouts to rows
        for workout in workouts.sorted(by: { $0.date > $1.date }) {
            let rows = flattenWorkout(workout)
            csvContent += rows.joined(separator: "\n")
            if !rows.isEmpty {
                csvContent += "\n"
            }
        }

        return csvContent
    }

    /// Save CSV to file
    /// - Parameters:
    ///   - csvContent: CSV string content
    ///   - filename: Filename (default: "antrain_export_YYYY-MM-DD.csv")
    /// - Returns: URL of saved file
    func saveToFile(_ csvContent: String, filename: String? = nil) throws -> URL {
        let fileName = filename ?? "antrain_export_\(dateString()).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    // MARK: - CSV Generation

    private func csvHeader() -> String {
        return "\"title\",\"start_time\",\"end_time\",\"description\",\"exercise_title\",\"exercise_notes\",\"set_index\",\"weight_kg\",\"reps\",\"distance_km\",\"duration_seconds\"\n"
    }

    private func flattenWorkout(_ workout: Workout) -> [String] {
        guard workout.type == .lifting else {
            // TODO: Support cardio/metcon export
            return []
        }

        var rows: [String] = []

        // Workout metadata
        let title = escapeCSV(workoutTitle(workout))
        let startTime = formatDate(workout.date)
        let endDate = workout.date.addingTimeInterval(workout.duration)
        let endTime = formatDate(endDate)
        let description = escapeCSV(workout.notes ?? "")

        // Iterate exercises
        for workoutExercise in workout.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            guard let exerciseName = workoutExercise.exercise?.name else { continue }

            let exerciseTitle = escapeCSV(exerciseName)

            // Iterate sets
            for (index, set) in workoutExercise.sets.enumerated() {
                let row = [
                    title,
                    startTime,
                    endTime,
                    description,
                    exerciseTitle,
                    escapeCSV(set.notes ?? ""),  // exercise_notes
                    String(index),  // set_index
                    formatWeight(set.weight),  // weight_kg
                    String(set.reps),  // reps
                    "",  // distance_km (not used for lifting)
                    ""  // duration_seconds (not used for sets)
                ]

                rows.append(row.joined(separator: ","))
            }
        }

        return rows
    }

    // MARK: - Helpers

    private func workoutTitle(_ workout: Workout) -> String {
        // Try to infer title from notes or use default
        if let notes = workout.notes, !notes.isEmpty {
            return notes
        }

        // Use date-based title
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return "\(formatter.string(from: workout.date)) Workout"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return escapeCSV(formatter.string(from: date))
    }

    private func formatWeight(_ weight: Double) -> String {
        return weight > 0 ? String(format: "%.1f", weight) : ""
    }

    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            // Escape quotes and wrap in quotes
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
