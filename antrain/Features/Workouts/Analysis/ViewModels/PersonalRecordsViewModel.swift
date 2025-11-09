import Foundation
import SwiftUI

/// View model for Personal Records Analysis
@MainActor
@Observable
final class PersonalRecordsViewModel {
    // MARK: - Dependencies

    private let personalRecordRepository: any PersonalRecordRepositoryProtocol
    private let exerciseRepository: any ExerciseRepositoryProtocol

    // MARK: - State

    var allPRs: [PersonalRecord] = []
    var exercises: [Exercise] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Filters

    var selectedDateRange: DateRange = .allTime
    var selectedMuscleGroup: MuscleGroup? = nil
    var searchText: String = ""

    // MARK: - Initialization

    init(
        personalRecordRepository: any PersonalRecordRepositoryProtocol,
        exerciseRepository: any ExerciseRepositoryProtocol
    ) {
        self.personalRecordRepository = personalRecordRepository
        self.exerciseRepository = exerciseRepository
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load PRs and exercises in parallel
            async let prsTask = personalRecordRepository.fetchAll()
            async let exercisesTask = exerciseRepository.fetchAll()

            let (prs, exs) = try await (prsTask, exercisesTask)

            allPRs = prs
            exercises = exs
            isLoading = false
        } catch {
            errorMessage = "Failed to load personal records"
            isLoading = false
        }
    }

    // MARK: - Computed Properties

    /// Filtered PRs based on date range, muscle group, and search
    var filteredPRs: [PersonalRecord] {
        var prs = allPRs

        // Date range filter
        if selectedDateRange != .allTime {
            let cutoffDate = selectedDateRange.startDate
            prs = prs.filter { $0.date >= cutoffDate }
        }

        // Muscle group filter
        if let muscleGroup = selectedMuscleGroup {
            let exerciseIds = exercises
                .filter { $0.muscleGroups.contains(muscleGroup) }
                .map(\.id)
            prs = prs.filter { exerciseIds.contains($0.exerciseId) }
        }

        // Search filter
        if !searchText.isEmpty {
            prs = prs.filter { $0.exerciseName.localizedCaseInsensitiveContains(searchText) }
        }

        return prs
    }

    /// PRs grouped by exercise name, sorted by date (newest first)
    var groupedPRs: [String: [PersonalRecord]] {
        Dictionary(grouping: filteredPRs) { $0.exerciseName }
    }

    /// Sorted exercise names from grouped PRs
    var sortedExerciseNames: [String] {
        groupedPRs.keys.sorted()
    }

    // MARK: - Statistics

    /// Total number of PRs (all time)
    var totalPRsCount: Int {
        allPRs.count
    }

    /// PRs achieved in last 30 days
    var last30DaysPRs: Int {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return allPRs.filter { $0.date >= thirtyDaysAgo }.count
    }

    /// PRs achieved in last 7 days
    var last7DaysPRs: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allPRs.filter { $0.date >= sevenDaysAgo }.count
    }

    /// Average PRs per week (last 12 weeks)
    var averagePRsPerWeek: Double {
        let twelveWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -12, to: Date()) ?? Date()
        let recentPRs = allPRs.filter { $0.date >= twelveWeeksAgo }

        guard !recentPRs.isEmpty else { return 0 }

        let weeks = 12.0
        return Double(recentPRs.count) / weeks
    }

    // MARK: - Chart Data

    /// Get PR history for a specific exercise (for chart)
    func getPRHistory(for exerciseName: String) -> [PersonalRecord] {
        allPRs
            .filter { $0.exerciseName == exerciseName }
            .sorted { $0.date < $1.date } // Oldest to newest for chart
    }

    /// Get muscle group for an exercise
    func getMuscleGroup(for exerciseId: UUID) -> MuscleGroup? {
        exercises.first { $0.id == exerciseId }?.primaryMuscleGroup
    }
}

// MARK: - Date Range

enum DateRange: String, CaseIterable, Identifiable {
    case last7Days
    case last30Days
    case last3Months
    case last6Months
    case allTime

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        case .last3Months: return "Last 3 Months"
        case .last6Months: return "Last 6 Months"
        case .allTime: return "All Time"
        }
    }

    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .last7Days:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .last30Days:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .last3Months:
            return calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .last6Months:
            return calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case .allTime:
            return .distantPast
        }
    }
}
