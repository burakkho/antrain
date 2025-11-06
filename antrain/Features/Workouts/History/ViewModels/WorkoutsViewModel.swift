import Foundation
import Observation

/// Workouts view model
/// Manages workout list, program schedule, and calendar integration
@Observable @MainActor
final class WorkoutsViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - State

    var workouts: [Workout] = []
    var calendarItems: [CalendarItem] = []
    var isLoading = true  // Start as loading to prevent white screen
    var errorMessage: String?

    // MARK: - Initialization

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol
    ) {
        self.workoutRepository = workoutRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Methods

    /// Load all workouts and build calendar items (includes program schedule)
    func loadWorkouts() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load workouts
            workouts = try await workoutRepository.fetchAll()

            // Load user profile (for active program)
            let userProfile = try await userProfileRepository.fetchOrCreateProfile()

            // Build calendar items
            await buildCalendarItems(
                workouts: workouts,
                activeProgram: userProfile.activeProgram,
                programStartDate: userProfile.activeProgramStartDate,
                currentWeekNumber: userProfile.currentWeekNumber
            )
        } catch {
            errorMessage = String(localized: "Failed to load workouts. Please try again.")
        }

        isLoading = false
    }

    /// Build unified calendar items from workouts and program schedule
    private func buildCalendarItems(
        workouts: [Workout],
        activeProgram: TrainingProgram?,
        programStartDate: Date?,
        currentWeekNumber: Int?
    ) async {
        let calendar = Calendar.current
        var items: [CalendarItem] = []

        // Add completed workouts
        for workout in workouts {
            items.append(CalendarItem(
                date: workout.date,
                type: .completed(workout)
            ))
        }

        // Add program schedule (if active program exists)
        if let program = activeProgram,
           let startDate = programStartDate,
           let currentWeek = currentWeekNumber {

            // Preload all relationships to avoid lazy loading issues
            // Access weeks, days, and templates to force SwiftData to load them
            for week in program.weeks {
                _ = week.days.compactMap { day in
                    _ = day.template // Touch template to force load
                    _ = day.template?.exercises // Touch exercises too
                    return day
                }
            }

            // Calculate dates for next 30 days
            let today = calendar.startOfDay(for: Date())

            for dayOffset in 0..<30 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                    continue
                }

                // Skip if workout already completed on this day
                let hasCompletedWorkout = workouts.contains { workout in
                    calendar.isDate(workout.date, inSameDayAs: date)
                }

                if hasCompletedWorkout {
                    continue
                }

                // Calculate which week and day this date corresponds to
                let daysSinceStart = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: date).day ?? 0
                let weekNumber = (daysSinceStart / 7) + 1
                let dayOfWeek = calendar.component(.weekday, from: date)

                // Get program day
                guard let week = program.weeks.first(where: { $0.weekNumber == weekNumber }),
                      let programDay = week.days.first(where: { $0.dayOfWeek == dayOfWeek }) else {
                    continue
                }

                // Add planned workout or rest day
                if programDay.template != nil {
                    items.append(CalendarItem(
                        date: date,
                        type: .planned(programDay, weekModifier: week.intensityModifier)
                    ))
                } else {
                    items.append(CalendarItem(
                        date: date,
                        type: .rest(programDay)
                    ))
                }
            }
        }

        // Sort by date
        calendarItems = items.sorted { $0.date < $1.date }
    }

    /// Delete workout
    func deleteWorkout(_ workout: Workout) async {
        do {
            try await workoutRepository.delete(workout)
            workouts.removeAll { $0.id == workout.id }
        } catch {
            errorMessage = String(localized: "Failed to delete workout.")
        }
    }
}
