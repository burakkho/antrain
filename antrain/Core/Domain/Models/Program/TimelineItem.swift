import Foundation
import SwiftUI // For Color and ViewBuilder

// MARK: - Supporting Types

public enum TimelineItemStatus {
    case completed
    case today
    case upcoming
    case future
    case rest

    var color: Color {
        switch self {
        case .completed: return .green
        case .today: return .blue
        case .upcoming: return .orange
        case .future: return .gray
        case .rest: return .blue
        }
    }

    @ViewBuilder
    var badge: some View {
        switch self {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .today:
            Text("Today", comment: "Today badge")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.blue)
                .clipShape(Capsule())
        case .upcoming:
            Text("Upcoming", comment: "Upcoming badge")
                .font(.caption)
                .foregroundStyle(.orange)
        case .future, .rest:
            EmptyView()
        }
    }
}

public struct TimelineItem: Identifiable {
    public let id = UUID()
    let date: Date
    let programDay: ProgramDay? // Assuming ProgramDay is accessible
    let completedWorkout: Workout? // Assuming Workout is accessible
    let status: TimelineItemStatus

    var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
