# Training Programs API Design (v2.0)

> **Status:** Planning Phase
> **Last Updated:** 2025-11-05

## Overview

This document provides the complete API design for the Training Programs feature, including all models, protocols, services, and ViewModels with their full method signatures and implementation notes.

---

## Table of Contents

1. [Domain Models](#domain-models)
2. [Repository Layer](#repository-layer)
3. [Service Layer](#service-layer)
4. [ViewModel Layer](#viewmodel-layer)
5. [Data Transfer Objects](#data-transfer-objects)
6. [Error Handling](#error-handling)
7. [Type Aliases](#type-aliases)

---

## Domain Models

### TrainingProgram

```swift
import Foundation
import SwiftData

/// Represents a complete training program (MacroCycle)
/// Contains multiple weeks with progressive overload built in
@Model
final class TrainingProgram: @unchecked Sendable {
    // MARK: - Identity

    /// Unique identifier
    @Attribute(.unique)
    var id: UUID

    /// Program name (e.g., "PPL 6-Day Split", "Starting Strength")
    var name: String

    /// Detailed description of program goals and methodology
    var description: String?

    // MARK: - Classification

    /// Program category for filtering and organization
    var category: ProgramCategory

    /// Target experience level
    var difficulty: DifficultyLevel

    /// Total program duration in weeks
    var durationWeeks: Int

    /// Whether this is a user-created program (vs preset)
    var isCustom: Bool

    // MARK: - Metadata

    /// When the program was created
    var createdAt: Date

    /// Last time program was modified
    var lastModifiedAt: Date

    // MARK: - Relationships

    /// All weeks in the program (cascade delete)
    @Relationship(deleteRule: .cascade, inverse: \ProgramWeek.program)
    var weeks: [ProgramWeek]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        category: ProgramCategory,
        difficulty: DifficultyLevel,
        durationWeeks: Int,
        isCustom: Bool = true,
        createdAt: Date = Date(),
        weeks: [ProgramWeek] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.durationWeeks = durationWeeks
        self.isCustom = isCustom
        self.createdAt = createdAt
        self.lastModifiedAt = createdAt
        self.weeks = weeks
    }

    // MARK: - Computed Properties

    /// Number of training days per week (average)
    var trainingDaysPerWeek: Int {
        guard !weeks.isEmpty else { return 0 }
        let totalDays = weeks.reduce(0) { $0 + $1.days.count }
        return totalDays / weeks.count
    }

    /// Whether this is a preset program (seeded by app)
    var isPreset: Bool {
        !isCustom
    }

    /// Total estimated duration in hours
    var totalEstimatedDuration: TimeInterval {
        weeks.reduce(0) { $0 + $1.estimatedDuration }
    }

    // MARK: - Business Logic

    /// Creates a deep copy of the program with a new name
    func duplicate(newName: String) -> TrainingProgram {
        let newProgram = TrainingProgram(
            name: newName,
            description: description,
            category: category,
            difficulty: difficulty,
            durationWeeks: durationWeeks,
            isCustom: true
        )

        // Deep copy weeks
        for week in weeks {
            let newWeek = week.duplicate(for: newProgram)
            newProgram.weeks.append(newWeek)
        }

        return newProgram
    }

    /// Validates program data
    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ProgramValidationError.emptyName
        }

        guard durationWeeks > 0 && durationWeeks <= 52 else {
            throw ProgramValidationError.invalidDuration
        }

        guard !weeks.isEmpty else {
            throw ProgramValidationError.noWeeks
        }

        // Validate each week
        for week in weeks {
            try week.validate()
        }
    }

    /// Marks the program as modified
    func markAsModified() {
        lastModifiedAt = Date()
    }
}
```

---

### ProgramWeek

```swift
import Foundation
import SwiftData

/// Represents a single week in a training program (MicroCycle)
@Model
final class ProgramWeek: @unchecked Sendable {
    // MARK: - Identity

    @Attribute(.unique)
    var id: UUID

    /// Week number within the program (1-based)
    var weekNumber: Int

    /// Optional week name (e.g., "Deload Week", "Testing Week")
    var name: String?

    /// Notes for this specific week
    var notes: String?

    // MARK: - Phase Tagging

    /// Optional training phase tag for visual organization
    var phaseTag: TrainingPhase?

    // MARK: - Progressive Overload

    /// Intensity multiplier for this week (1.0 = baseline)
    /// Example: 1.05 = +5% intensity, 0.6 = deload
    var intensityModifier: Double

    /// Volume multiplier for this week (1.0 = baseline)
    /// Example: 0.6 = deload, 1.1 = overreach
    var volumeModifier: Double

    /// Whether this is a deload week
    var isDeload: Bool

    // MARK: - Relationships

    /// Parent program
    var program: TrainingProgram

    /// All training days in this week (cascade delete)
    @Relationship(deleteRule: .cascade, inverse: \ProgramDay.week)
    var days: [ProgramDay]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        weekNumber: Int,
        name: String? = nil,
        notes: String? = nil,
        phaseTag: TrainingPhase? = nil,
        intensityModifier: Double = 1.0,
        volumeModifier: Double = 1.0,
        isDeload: Bool = false,
        program: TrainingProgram,
        days: [ProgramDay] = []
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.name = name
        self.notes = notes
        self.phaseTag = phaseTag
        self.intensityModifier = intensityModifier
        self.volumeModifier = volumeModifier
        self.isDeload = isDeload
        self.program = program
        self.days = days
    }

    // MARK: - Computed Properties

    /// Estimated duration for this week (sum of all days)
    var estimatedDuration: TimeInterval {
        days.reduce(0) { $0 + ($1.template?.estimatedDuration ?? 0) }
    }

    /// Number of training days this week
    var trainingDayCount: Int {
        days.count
    }

    /// Display name (fallback to "Week N")
    var displayName: String {
        name ?? "Week \(weekNumber)"
    }

    // MARK: - Business Logic

    /// Creates a deep copy for a new program
    func duplicate(for newProgram: TrainingProgram) -> ProgramWeek {
        let newWeek = ProgramWeek(
            weekNumber: weekNumber,
            name: name,
            notes: notes,
            phaseTag: phaseTag,
            intensityModifier: intensityModifier,
            volumeModifier: volumeModifier,
            isDeload: isDeload,
            program: newProgram
        )

        // Deep copy days
        for day in days {
            let newDay = day.duplicate(for: newWeek)
            newWeek.days.append(newDay)
        }

        return newWeek
    }

    /// Validates week data
    func validate() throws {
        guard weekNumber > 0 else {
            throw ProgramValidationError.invalidWeekNumber
        }

        guard intensityModifier > 0 && intensityModifier <= 2.0 else {
            throw ProgramValidationError.invalidModifier
        }

        guard volumeModifier > 0 && volumeModifier <= 2.0 else {
            throw ProgramValidationError.invalidModifier
        }

        // Validate each day
        for day in days {
            try day.validate()
        }
    }
}
```

---

### ProgramDay

```swift
import Foundation
import SwiftData

/// Represents a single training day in a week
@Model
final class ProgramDay: @unchecked Sendable {
    // MARK: - Identity

    @Attribute(.unique)
    var id: UUID

    /// Day of week (1 = Monday, 7 = Sunday)
    var dayOfWeek: Int

    /// Optional day name (e.g., "Upper Power", "Push Day")
    var name: String?

    /// Notes for this specific day
    var notes: String?

    // MARK: - Relationships

    /// Parent week
    var week: ProgramWeek

    /// Referenced workout template (optional - can be deleted)
    var template: WorkoutTemplate?

    // MARK: - Day-Specific Overrides

    /// Optional intensity override (overrides week modifier)
    var intensityOverride: Double?

    /// Optional volume override (overrides week modifier)
    var volumeOverride: Double?

    /// Suggested RPE for this day (1-10)
    var suggestedRPE: Int?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        dayOfWeek: Int,
        name: String? = nil,
        notes: String? = nil,
        week: ProgramWeek,
        template: WorkoutTemplate? = nil,
        intensityOverride: Double? = nil,
        volumeOverride: Double? = nil,
        suggestedRPE: Int? = nil
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.name = name
        self.notes = notes
        self.week = week
        self.template = template
        self.intensityOverride = intensityOverride
        self.volumeOverride = volumeOverride
        self.suggestedRPE = suggestedRPE
    }

    // MARK: - Computed Properties

    /// Effective intensity (override or week modifier)
    var effectiveIntensity: Double {
        intensityOverride ?? week.intensityModifier
    }

    /// Effective volume (override or week modifier)
    var effectiveVolume: Double {
        volumeOverride ?? week.volumeModifier
    }

    /// Day name for display (template name or "Rest Day")
    var displayName: String {
        if let name = name {
            return name
        } else if let template = template {
            return template.name
        } else {
            return "Rest Day"
        }
    }

    /// Whether this is a rest day (no template assigned)
    var isRestDay: Bool {
        template == nil
    }

    /// Day of week as string
    var dayOfWeekString: String {
        Calendar.current.weekdaySymbols[dayOfWeek - 1]
    }

    // MARK: - Business Logic

    /// Creates a duplicate for a new week
    func duplicate(for newWeek: ProgramWeek) -> ProgramDay {
        ProgramDay(
            dayOfWeek: dayOfWeek,
            name: name,
            notes: notes,
            week: newWeek,
            template: template,  // Same template reference
            intensityOverride: intensityOverride,
            volumeOverride: volumeOverride,
            suggestedRPE: suggestedRPE
        )
    }

    /// Validates day data
    func validate() throws {
        guard dayOfWeek >= 1 && dayOfWeek <= 7 else {
            throw ProgramValidationError.invalidDayOfWeek
        }

        if let rpe = suggestedRPE {
            guard rpe >= 1 && rpe <= 10 else {
                throw ProgramValidationError.invalidRPE
            }
        }

        if let intensity = intensityOverride {
            guard intensity > 0 && intensity <= 2.0 else {
                throw ProgramValidationError.invalidModifier
            }
        }

        if let volume = volumeOverride {
            guard volume > 0 && volume <= 2.0 else {
                throw ProgramValidationError.invalidModifier
            }
        }
    }
}
```

---

### Supporting Enums

```swift
// MARK: - Program Category

enum ProgramCategory: String, Codable, CaseIterable {
    case powerlifting = "Powerlifting"
    case bodybuilding = "Bodybuilding"
    case strengthTraining = "Strength Training"
    case crossfit = "CrossFit"
    case generalFitness = "General Fitness"
    case sportSpecific = "Sport Specific"

    var displayName: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .powerlifting: return "figure.strengthtraining.traditional"
        case .bodybuilding: return "figure.mixed.cardio"
        case .strengthTraining: return "dumbbell.fill"
        case .crossfit: return "flame.fill"
        case .generalFitness: return "figure.walk"
        case .sportSpecific: return "sportscourt.fill"
        }
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var displayName: String {
        rawValue
    }

    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

// MARK: - Training Phase

enum TrainingPhase: String, Codable, CaseIterable {
    case hypertrophy = "Hypertrophy"
    case strength = "Strength"
    case peaking = "Peaking"
    case deload = "Deload"
    case testing = "Testing"

    var displayName: String {
        rawValue
    }

    var description: String {
        switch self {
        case .hypertrophy:
            return "High volume, moderate intensity. Focus on muscle growth."
        case .strength:
            return "Moderate volume, high intensity. Focus on maximum strength."
        case .peaking:
            return "Low volume, very high intensity. Prepare for competition."
        case .deload:
            return "Reduced volume and intensity. Recovery week."
        case .testing:
            return "1RM testing week. Minimal volume."
        }
    }

    var color: String {
        switch self {
        case .hypertrophy: return "blue"
        case .strength: return "purple"
        case .peaking: return "red"
        case .deload: return "green"
        case .testing: return "orange"
        }
    }
}

// MARK: - Week Progression Pattern

enum WeekProgressionPattern: String, Codable, CaseIterable {
    case linear = "Linear"
    case wave = "Wave"
    case threeOneDeload = "3-1 Deload"
    case fourOneDeload = "4-1 Deload"
    case custom = "Custom"

    var displayName: String {
        rawValue
    }

    var description: String {
        switch self {
        case .linear:
            return "Consistent increase each week"
        case .wave:
            return "Up and down pattern for recovery"
        case .threeOneDeload:
            return "3 weeks progressive, 1 deload"
        case .fourOneDeload:
            return "4 weeks progressive, 1 deload"
        case .custom:
            return "User-defined progression"
        }
    }

    /// Generate intensity modifiers for given number of weeks
    func generateModifiers(
        weeks: Int,
        baseIntensity: Double = 1.0,
        increment: Double = 0.025
    ) -> [Double] {
        var modifiers: [Double] = []

        switch self {
        case .linear:
            for i in 0..<weeks {
                modifiers.append(baseIntensity + (Double(i) * increment))
            }

        case .wave:
            for i in 0..<weeks {
                let cycle = i % 3
                let offset = Double(i / 3) * increment * 3
                let waveModifier = [0.0, increment, -increment][cycle]
                modifiers.append(baseIntensity + offset + waveModifier)
            }

        case .threeOneDeload:
            for i in 0..<weeks {
                if (i + 1) % 4 == 0 {
                    modifiers.append(0.6)  // Deload
                } else {
                    let progressWeek = i - (i / 4)
                    modifiers.append(baseIntensity + (Double(progressWeek) * increment))
                }
            }

        case .fourOneDeload:
            for i in 0..<weeks {
                if (i + 1) % 5 == 0 {
                    modifiers.append(0.6)  // Deload
                } else {
                    let progressWeek = i - (i / 5)
                    modifiers.append(baseIntensity + (Double(progressWeek) * increment))
                }
            }

        case .custom:
            // Return flat baseline, user will customize
            modifiers = Array(repeating: baseIntensity, count: weeks)
        }

        return modifiers
    }
}
```

---

## Repository Layer

### Protocol

```swift
import Foundation

/// Protocol defining TrainingProgram repository operations
protocol TrainingProgramRepositoryProtocol: Actor {
    // MARK: - CRUD

    /// Creates a new training program
    func create(_ program: TrainingProgram) async throws

    /// Fetches all programs (user + presets)
    func fetchAll() async throws -> [TrainingProgram]

    /// Fetches program by ID
    func fetchById(_ id: UUID) async throws -> TrainingProgram?

    /// Fetches programs by category
    func fetchByCategory(_ category: ProgramCategory) async throws -> [TrainingProgram]

    /// Fetches only user-created programs
    func fetchUserPrograms() async throws -> [TrainingProgram]

    /// Fetches only preset programs
    func fetchPresetPrograms() async throws -> [TrainingProgram]

    /// Updates existing program
    func update(_ program: TrainingProgram) async throws

    /// Deletes program
    func delete(_ program: TrainingProgram) async throws

    // MARK: - Template Usage

    /// Finds all programs using a specific template
    func findProgramsUsingTemplate(_ template: WorkoutTemplate) async throws -> [TrainingProgram]

    // MARK: - Presets

    /// Seeds preset programs (idempotent)
    func seedPresetPrograms() async throws

    /// Checks if presets have been seeded
    func hasPresetPrograms() async throws -> Bool

    // MARK: - Duplication

    /// Duplicates a program with a new name
    func duplicateProgram(_ program: TrainingProgram, newName: String) async throws -> TrainingProgram

    // MARK: - Validation

    /// Checks if program name is unique
    func isProgramNameUnique(_ name: String, excludingId: UUID?) async throws -> Bool
}
```

### Implementation

```swift
import Foundation
import SwiftData

@ModelActor
actor TrainingProgramRepository: TrainingProgramRepositoryProtocol {
    // Implementation details in IMPLEMENTATION_PLAN.md
}
```

---

## Service Layer

### ProgressiveOverloadService

```swift
import Foundation

/// Service for calculating progressive overload suggestions
@MainActor
final class ProgressiveOverloadService {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol

    // MARK: - Initialization

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    // MARK: - Public API

    /// Suggests workout with adjusted weights based on previous performance
    func suggestWorkout(
        for template: WorkoutTemplate,
        weekModifier: Double,
        previousWorkouts: [Workout]
    ) -> SuggestedWorkout {
        var suggestions: [ExerciseSuggestion] = []

        for templateExercise in template.exercises {
            guard let exercise = templateExercise.exercise else { continue }

            let lastPerformance = findLastPerformance(
                exercise: exercise,
                in: previousWorkouts
            )

            let suggestion = calculateSuggestion(
                for: templateExercise,
                lastPerformance: lastPerformance,
                weekModifier: weekModifier
            )

            suggestions.append(suggestion)
        }

        return SuggestedWorkout(
            template: template,
            suggestions: suggestions,
            weekModifier: weekModifier
        )
    }

    /// Fetches recent workouts for analysis
    func fetchRecentWorkouts(limit: Int = 10) async throws -> [Workout] {
        try await workoutRepository.fetchRecent(limit: limit)
    }

    // MARK: - Private Methods

    private func findLastPerformance(
        exercise: Exercise,
        in workouts: [Workout]
    ) -> WorkoutExercise? {
        for workout in workouts.sorted(by: { $0.date > $1.date }) {
            if let match = workout.exercises.first(where: { $0.exercise?.id == exercise.id }) {
                return match
            }
        }
        return nil
    }

    private func calculateSuggestion(
        for templateExercise: TemplateExercise,
        lastPerformance: WorkoutExercise?,
        weekModifier: Double
    ) -> ExerciseSuggestion {
        guard let lastPerformance = lastPerformance else {
            // First time - use template weight
            return ExerciseSuggestion(
                exercise: templateExercise.exercise!,
                suggestedWeight: templateExercise.weight * weekModifier,
                suggestedSets: templateExercise.setCount,
                suggestedReps: templateExercise.repRangeMin,
                reason: "First time - using template weight"
            )
        }

        // Get last RPE from workout
        let lastRPE = lastPerformance.workout?.rpe

        // Calculate RPE-based adjustment
        let rpeModifier = calculateRPEModifier(rpe: lastRPE)

        // Get last actual weight
        let lastWeight = lastPerformance.sets.last?.weight ?? templateExercise.weight

        // Calculate suggestion
        let suggestedWeight = lastWeight * rpeModifier * weekModifier

        let reason = generateReason(rpe: lastRPE, modifier: rpeModifier)

        return ExerciseSuggestion(
            exercise: templateExercise.exercise!,
            suggestedWeight: suggestedWeight,
            suggestedSets: templateExercise.setCount,
            suggestedReps: templateExercise.repRangeMin,
            reason: reason
        )
    }

    private func calculateRPEModifier(rpe: Int?) -> Double {
        guard let rpe = rpe else { return 1.025 }  // No RPE data, small increase

        switch rpe {
        case 1...6:
            return 1.05  // Too easy, bigger jump (+5%)
        case 7...8:
            return 1.025  // Perfect, small increase (+2.5%)
        case 9...10:
            return 0.975  // Too hard, decrease (-2.5%)
        default:
            return 1.0
        }
    }

    private func generateReason(rpe: Int?, modifier: Double) -> String {
        guard let rpe = rpe else {
            return "Standard progression"
        }

        switch rpe {
        case 1...6:
            return "Last workout was easy (RPE \(rpe)) - increasing weight"
        case 7...8:
            return "Good progression (RPE \(rpe))"
        case 9...10:
            return "Last workout was too hard (RPE \(rpe)) - reducing weight"
        default:
            return "Standard progression"
        }
    }
}

// MARK: - Supporting Types

struct SuggestedWorkout {
    let template: WorkoutTemplate
    let suggestions: [ExerciseSuggestion]
    let weekModifier: Double
}

struct ExerciseSuggestion {
    let exercise: Exercise
    let suggestedWeight: Double
    let suggestedSets: Int
    let suggestedReps: Int
    let reason: String
}
```

---

## ViewModel Layer

### ProgramsListViewModel

```swift
import Foundation
import SwiftUI

@Observable
@MainActor
final class ProgramsListViewModel {
    // MARK: - State

    private(set) var programs: [TrainingProgram] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    var selectedCategory: ProgramCategory?
    var searchText: String = ""

    // MARK: - Dependencies

    private let repository: TrainingProgramRepositoryProtocol

    // MARK: - Initialization

    init(repository: TrainingProgramRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func loadPrograms() async {
        isLoading = true
        error = nil

        do {
            if let category = selectedCategory {
                programs = try await repository.fetchByCategory(category)
            } else {
                programs = try await repository.fetchAll()
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func deleteProgram(_ program: TrainingProgram) async {
        do {
            try await repository.delete(program)
            await loadPrograms()
        } catch {
            self.error = error
        }
    }

    func filterByCategory(_ category: ProgramCategory?) {
        selectedCategory = category
        Task {
            await loadPrograms()
        }
    }

    // MARK: - Computed

    var filteredPrograms: [TrainingProgram] {
        if searchText.isEmpty {
            return programs
        }
        return programs.filter { program in
            program.name.localizedCaseInsensitiveContains(searchText) ||
            program.description?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    var userPrograms: [TrainingProgram] {
        filteredPrograms.filter { $0.isCustom }
    }

    var presetPrograms: [TrainingProgram] {
        filteredPrograms.filter { !$0.isCustom }
    }
}
```

### ProgramDetailViewModel

```swift
import Foundation
import SwiftUI

@Observable
@MainActor
final class ProgramDetailViewModel {
    // MARK: - State

    private(set) var program: TrainingProgram
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Dependencies

    private let repository: TrainingProgramRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - Initialization

    init(
        program: TrainingProgram,
        repository: TrainingProgramRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.program = program
        self.repository = repository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Public Methods

    func activateProgram() async {
        isLoading = true
        error = nil

        do {
            let profile = try await userProfileRepository.getCurrentProfile()
            profile.activateProgram(program)
            try await userProfileRepository.save(profile)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func deactivateProgram() async {
        isLoading = true
        error = nil

        do {
            let profile = try await userProfileRepository.getCurrentProfile()
            profile.deactivateProgram()
            try await userProfileRepository.save(profile)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func deleteProgram() async throws {
        try await repository.delete(program)
    }

    func duplicateProgram(newName: String) async throws -> TrainingProgram {
        try await repository.duplicateProgram(program, newName: newName)
    }

    // MARK: - Computed

    var weeksByPhase: [TrainingPhase: [ProgramWeek]] {
        Dictionary(grouping: program.weeks, by: { $0.phaseTag ?? .hypertrophy })
    }

    var completionPercentage: Double {
        // Would need to track completed weeks
        0.0  // Placeholder
    }
}
```

---

## Data Transfer Objects

```swift
// Used for preset program seeding

struct ProgramDTO {
    let id: UUID
    let name: String
    let description: String
    let category: ProgramCategory
    let difficulty: DifficultyLevel
    let weeks: [WeekDTO]
}

struct WeekDTO {
    let weekNumber: Int
    let name: String?
    let phaseTag: TrainingPhase?
    let intensityModifier: Double
    let volumeModifier: Double
    let isDeload: Bool
    let days: [DayDTO]
}

struct DayDTO {
    let dayOfWeek: Int
    let name: String?
    let templateName: String  // Reference by name
    let notes: String?
    let suggestedRPE: Int?
}
```

---

## Error Handling

```swift
// MARK: - Validation Errors

enum ProgramValidationError: LocalizedError {
    case emptyName
    case invalidDuration
    case noWeeks
    case invalidWeekNumber
    case invalidModifier
    case invalidDayOfWeek
    case invalidRPE

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Program name cannot be empty"
        case .invalidDuration:
            return "Duration must be between 1 and 52 weeks"
        case .noWeeks:
            return "Program must contain at least one week"
        case .invalidWeekNumber:
            return "Week number must be positive"
        case .invalidModifier:
            return "Modifier must be between 0 and 2.0"
        case .invalidDayOfWeek:
            return "Day of week must be between 1 and 7"
        case .invalidRPE:
            return "RPE must be between 1 and 10"
        }
    }
}

// MARK: - Repository Errors

enum TrainingProgramRepositoryError: LocalizedError {
    case duplicateName
    case programNotFound
    case invalidProgram
    case cannotDeletePreset

    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "A program with this name already exists"
        case .programNotFound:
            return "Program not found"
        case .invalidProgram:
            return "Program data is invalid"
        case .cannotDeletePreset:
            return "Preset programs cannot be deleted"
        }
    }
}
```

---

## Type Aliases

```swift
/// Completion handler for async operations
typealias CompletionHandler = () -> Void

/// Error handler
typealias ErrorHandler = (Error) -> Void

/// Progress callback (0.0 - 1.0)
typealias ProgressCallback = (Double) -> Void
```

---

## References

- [Architecture Document](./TRAINING_PROGRAMS.md)
- [Implementation Plan](./IMPLEMENTATION_PLAN.md)
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

---

**Document Version:** 1.0
**Status:** Complete
**Next Review:** After Phase 1 implementation
