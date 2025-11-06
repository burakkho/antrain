import Foundation

/// Unified calendar item for both completed workouts and planned program days
struct CalendarItem: Identifiable {
    let id = UUID()
    let date: Date
    let type: CalendarItemType

    /// Type of calendar item
    enum CalendarItemType {
        case completed(Workout)
        case planned(ProgramDay, weekModifier: Double)
        case rest(ProgramDay)

        var isCompleted: Bool {
            if case .completed = self { return true }
            return false
        }

        var isPlanned: Bool {
            if case .planned = self { return true }
            return false
        }

        var isRest: Bool {
            if case .rest = self { return true }
            return false
        }

        var workout: Workout? {
            if case .completed(let workout) = self { return workout }
            return nil
        }

        var programDay: ProgramDay? {
            switch self {
            case .completed: return nil
            case .planned(let day, _): return day
            case .rest(let day): return day
            }
        }
    }

    // MARK: - Display Properties

    var title: String {
        switch type {
        case .completed(let workout):
            return workout.type.displayName
        case .planned(let day, _):
            return day.displayName
        case .rest:
            return String(localized: "Rest Day")
        }
    }

    var subtitle: String? {
        switch type {
        case .completed(let workout):
            return workoutSubtitle(workout)
        case .planned(let day, _):
            if let template = day.template {
                return "\(template.exerciseCount) exercises"
            }
            return nil
        case .rest:
            return "Recovery"
        }
    }

    var icon: String {
        switch type {
        case .completed(let workout):
            return workoutIcon(workout.type)
        case .planned(let day, _):
            if let template = day.template {
                return template.category.icon
            }
            return "dumbbell.fill"
        case .rest:
            return "moon.zzz.fill"
        }
    }

    // MARK: - Helpers

    private func workoutIcon(_ type: WorkoutType) -> String {
        switch type {
        case .lifting: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .metcon: return "flame.fill"
        }
    }

    private func workoutSubtitle(_ workout: Workout) -> String? {
        switch workout.type {
        case .lifting:
            let count = workout.exercises.count
            return "\(count) exercise\(count == 1 ? "" : "s")"
        case .cardio, .metcon:
            if workout.duration > 0 {
                let minutes = Int(workout.duration / 60)
                return "\(minutes) min"
            }
            return nil
        }
    }
}
