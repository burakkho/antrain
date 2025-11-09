//
//  CSVImportService.swift
//  antrain
//
//  Created by Claude Code on 2025-02-11.
//  Import workouts from CSV format (Hevy, Strong, Fitbod compatible)
//

import Foundation
import SwiftData

/// Service for importing workouts from CSV format (compatible with Hevy, Strong, Fitbod exports)
@MainActor
class CSVImportService {
    private let exerciseNameMapper: ExerciseNameMapper
    private let exerciseRepository: ExerciseRepository

    init(
        exerciseNameMapper: ExerciseNameMapper,
        exerciseRepository: ExerciseRepository
    ) {
        self.exerciseNameMapper = exerciseNameMapper
        self.exerciseRepository = exerciseRepository
    }

    // MARK: - Public API

    /// Import workouts from CSV file
    /// - Parameter fileURL: URL to the CSV file
    /// - Returns: Tuple with imported workouts and number of fixed outliers
    /// - Throws: CSVImportError if parsing fails
    func importWorkouts(from fileURL: URL) async throws -> (workouts: [Workout], fixedOutliers: Int) {
        // Read CSV content
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw CSVImportError.fileAccessDenied
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }

        let csvContent: String
        do {
            csvContent = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw CSVImportError.fileReadFailed(error)
        }

        // Reset outlier counter
        fixedOutliersCount = 0

        // Parse CSV
        let workouts = try await parseHevyCSV(csvContent)

        return (workouts, fixedOutliersCount)
    }

    // Track outliers fixed during import
    private var fixedOutliersCount = 0

    // MARK: - CSV Parsing

    /// Parse CSV format (Hevy/Strong/Fitbod compatible)
    /// Expected columns: title, start_time, end_time, description, exercise_title,
    ///                   superset_id, exercise_notes, set_index, set_type,
    ///                   weight_kg, reps, distance_km, duration_seconds, rpe
    private func parseHevyCSV(_ csvContent: String) async throws -> [Workout] {
        let lines = csvContent.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw CSVImportError.emptyFile
        }

        // Parse header
        let header = parseCSVLine(lines[0])
        guard validateHeader(header) else {
            throw CSVImportError.invalidHeader
        }

        // Parse rows (skip header)
        var csvRows: [CSVRow] = []
        for (index, line) in lines.dropFirst().enumerated() {
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }

            do {
                let row = try parseCSVRow(line, header: header, lineNumber: index + 2)
                csvRows.append(row)
            } catch {
                // Skip invalid rows but log them
                print("Warning: Skipping row \(index + 2): \(error)")
                continue
            }
        }

        // Group rows by workout (title + start_time)
        let workouts = try await groupAndBuildWorkouts(from: csvRows)

        return workouts
    }

    /// Parse a single CSV line respecting quotes
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        fields.append(currentField)  // Add last field

        return fields.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private func validateHeader(_ header: [String]) -> Bool {
        let requiredColumns = ["title", "start_time", "end_time", "exercise_title", "set_index", "weight_kg", "reps"]
        return requiredColumns.allSatisfy { header.contains($0) }
    }

    private func parseCSVRow(_ line: String, header: [String], lineNumber: Int) throws -> CSVRow {
        let fields = parseCSVLine(line)
        guard fields.count == header.count else {
            throw CSVImportError.invalidRowFormat(lineNumber)
        }

        var rowData: [String: String] = [:]
        for (index, columnName) in header.enumerated() {
            rowData[columnName] = fields[index]
        }

        return CSVRow(data: rowData, lineNumber: lineNumber)
    }

    // MARK: - Workout Building

    private func groupAndBuildWorkouts(from rows: [CSVRow]) async throws -> [Workout] {
        // Detect and fix outliers before building workouts
        let cleanedRows = detectAndFixOutliers(rows)

        // Group by (title + start_time)
        var workoutGroups: [String: [CSVRow]] = [:]

        for row in cleanedRows {
            guard let title = row.string("title"),
                  let startTime = row.string("start_time") else { continue }

            let key = "\(title)|\(startTime)"
            workoutGroups[key, default: []].append(row)
        }

        // Build workouts
        var workouts: [Workout] = []

        for (_, group) in workoutGroups.sorted(by: { $0.key < $1.key }) {
            if let workout = try await buildWorkout(from: group) {
                workouts.append(workout)
            }
        }

        return workouts
    }

    // MARK: - Outlier Detection

    /// Detect and fix outlier weights (typos like 440kg instead of 44kg)
    private func detectAndFixOutliers(_ rows: [CSVRow]) -> [CSVRow] {
        // Group by exercise
        var exerciseWeights: [String: [Double]] = [:]

        for row in rows {
            guard let exercise = row.string("exercise_title"),
                  let weight = row.double("weight_kg"),
                  weight > 0 else { continue }

            exerciseWeights[exercise, default: []].append(weight)
        }

        // Calculate median for each exercise
        var exerciseMedians: [String: Double] = [:]
        for (exercise, weights) in exerciseWeights {
            guard weights.count >= 3 else { continue } // Need at least 3 sets for reliable detection
            let sorted = weights.sorted()
            let median = sorted[sorted.count / 2]
            exerciseMedians[exercise] = median
        }

        // Fix outliers
        var fixedRows: [CSVRow] = []
        var fixCount = 0

        for row in rows {
            guard let exercise = row.string("exercise_title"),
                  let median = exerciseMedians[exercise],
                  let weight = row.double("weight_kg"),
                  weight > 0 else {
                fixedRows.append(row)
                continue
            }

            // Check if weight is 5x higher than median (likely typo: 440 instead of 44)
            if weight > median * 5 {
                // Fix by dividing by 10 (most common typo pattern)
                let fixedWeight = weight / 10

                // Only fix if the result is close to median (within 2x)
                if fixedWeight > median * 0.3 && fixedWeight < median * 3 {
                    print("⚠️ Fixed outlier: \(exercise) \(weight)kg → \(fixedWeight)kg (median: \(median)kg)")

                    // Create fixed row
                    var fixedData = row.data
                    fixedData["weight_kg"] = String(fixedWeight)
                    let fixedRow = CSVRow(data: fixedData, lineNumber: row.lineNumber)
                    fixedRows.append(fixedRow)
                    fixCount += 1
                    continue
                }
            }

            fixedRows.append(row)
        }

        if fixCount > 0 {
            fixedOutliersCount += fixCount
            print("✅ Fixed \(fixCount) outlier weights automatically")
        }

        return fixedRows
    }

    private func buildWorkout(from rows: [CSVRow]) async throws -> Workout? {
        guard let firstRow = rows.first else { return nil }

        // Extract workout metadata
        guard let startTimeStr = firstRow.string("start_time"),
              let endTimeStr = firstRow.string("end_time") else {
            return nil
        }

        let startDate = parseDate(startTimeStr) ?? Date()
        let endDate = parseDate(endTimeStr) ?? startDate
        let duration = endDate.timeIntervalSince(startDate)

        // Create workout
        let workout = Workout(
            date: startDate,
            type: .lifting,  // Most CSV exports are lifting workouts
            duration: duration,
            notes: firstRow.string("description")
        )

        // Group rows by exercise
        var exerciseGroups: [String: [CSVRow]] = [:]
        for row in rows {
            guard let exerciseName = row.string("exercise_title") else { continue }
            exerciseGroups[exerciseName, default: []].append(row)
        }

        // Build exercises
        for (exerciseName, exerciseRows) in exerciseGroups.sorted(by: { $0.key < $1.key }) {
            if let workoutExercise = try await buildExercise(
                name: exerciseName,
                rows: exerciseRows,
                workout: workout
            ) {
                workout.addExercise(workoutExercise)
            }
        }

        return workout
    }

    private func buildExercise(
        name: String,
        rows: [CSVRow],
        workout: Workout
    ) async throws -> WorkoutExercise? {
        // Find or create exercise in library
        let exercise = try await exerciseNameMapper.findOrCreateExercise(name: name)

        // Get superset_id if exists
        let supersetId = rows.first?.string("superset_id")

        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            orderIndex: workout.exercises.count,
            supersetId: supersetId
        )

        // Build sets (sorted by set_index)
        let sortedRows = rows.sorted { ($0.int("set_index") ?? 0) < ($1.int("set_index") ?? 0) }

        for row in sortedRows {
            if let set = buildSet(from: row) {
                workoutExercise.addSet(set)
            }
        }

        return workoutExercise.sets.isEmpty ? nil : workoutExercise
    }

    private func buildSet(from row: CSVRow) -> WorkoutSet? {
        guard let reps = row.int("reps"), reps > 0 else { return nil }

        let weight = row.double("weight_kg") ?? 0.0
        let setType = row.string("set_type")
        let rpe = row.int("rpe")

        // Debug logging for PR issue investigation
        if let exerciseName = row.string("exercise_title"), weight > 0 {
            let estimated1RM = OneRepMaxCalculator.brzycki(weight: weight, reps: reps)
            print("📊 CSV Import - \(exerciseName): \(weight)kg × \(reps) reps = \(String(format: "%.0f", estimated1RM))kg 1RM")
        }

        return WorkoutSet(
            reps: reps,
            weight: weight,
            isCompleted: true,  // CSV exports are completed workouts
            notes: row.string("exercise_notes"),
            setType: setType,
            rpe: rpe
        )
    }

    // MARK: - Date Parsing

    private func parseDate(_ dateString: String) -> Date? {
        // Common CSV format: "4 Feb 2025, 16:21" or "4 Şub 2025, 16:21" or "4 Kas 2023, 14:52"
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm"

        // Try multiple locales
        let locales = [
            Locale(identifier: "tr_TR"),  // Turkish: Şub, Kas, Oca, etc.
            Locale(identifier: "en_US"),  // English: Feb, Nov, Jan, etc.
            Locale(identifier: "en_GB")
        ]

        for locale in locales {
            formatter.locale = locale
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        // Fallback to current date if parsing fails (better than nil)
        print("⚠️ Could not parse date: \(dateString), using current date")
        return Date()
    }
}

// MARK: - CSV Row Helper

private struct CSVRow {
    let data: [String: String]
    let lineNumber: Int

    func string(_ key: String) -> String? {
        let value = data[key]?.trimmingCharacters(in: .whitespaces)
        return value?.isEmpty == true ? nil : value
    }

    func int(_ key: String) -> Int? {
        guard let str = string(key) else { return nil }
        return Int(str)
    }

    func double(_ key: String) -> Double? {
        guard let str = string(key) else { return nil }
        return Double(str)
    }
}

// MARK: - Errors

enum CSVImportError: LocalizedError {
    case fileAccessDenied
    case fileReadFailed(Error)
    case emptyFile
    case invalidHeader
    case invalidRowFormat(Int)

    var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            return "Could not access the file. Please try again."
        case .fileReadFailed(let error):
            return "Failed to read file: \(error.localizedDescription)"
        case .emptyFile:
            return "The CSV file is empty."
        case .invalidHeader:
            return "Invalid CSV format. Expected standard workout export format."
        case .invalidRowFormat(let line):
            return "Invalid row format at line \(line)."
        }
    }
}
