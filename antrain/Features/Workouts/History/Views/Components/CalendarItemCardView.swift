import SwiftUI

/// Calendar item card view with swipe actions for completed/planned/rest items
struct CalendarItemCardView: View {
    let item: CalendarItem
    let onDelete: ((Workout) -> Void)?
    let onStartWorkout: ((WorkoutTemplate, ProgramDay) -> Void)?
    let onPreview: ((ProgramDay, Double) -> Void)?

    var body: some View {
        Group {
            switch item.type {
            case .completed(let workout):
                // Completed workout - navigate to detail
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    itemCardContent
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        onDelete?(workout)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }

            case .planned(let programDay, let weekModifier):
                // Planned workout - tap to preview, swipe to start/skip
                Group {
                    if programDay.template != nil {
                        Button {
                            onPreview?(programDay, weekModifier)
                        } label: {
                            itemCardContent
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Template not available - show non-interactive card
                        itemCardContent
                            .opacity(0.5)
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        // Start workout
                        if let template = programDay.template {
                            onStartWorkout?(template, programDay)
                        }
                    } label: {
                        Label("Start", systemImage: "play.fill")
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        // Skip workout (mark as completed with empty data)
                        // TODO: Implement skip logic
                    } label: {
                        Label("Skip", systemImage: "forward.fill")
                    }
                    .tint(.orange)
                }

            case .rest:
                // Rest day - no actions
                itemCardContent
            }
        }
    }

    // MARK: - Item Card Content

    private var itemCardContent: some View {
        HStack(spacing: DSSpacing.sm) {
            // Icon with status indicator
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundStyle(itemColor)
                    .frame(width: 40, height: 40)

                // Status badge
                if item.type.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .background(Circle().fill(.green).frame(width: 16, height: 16))
                        .offset(x: 4, y: 4)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(DSTypography.subheadline)
                    .fontWeight(item.type.isCompleted ? .semibold : .regular)
                    .foregroundStyle(DSColors.textPrimary)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                }

                // Type indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(itemColor)
                        .frame(width: 6, height: 6)

                    Text(itemTypeLabel)
                        .font(.caption2)
                        .foregroundStyle(itemColor)
                }
            }

            Spacer()

            // Chevron for completed and planned workouts
            if item.type.isCompleted || item.type.isPlanned {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
        .padding(DSSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .overlay {
            // Border styling
            RoundedRectangle(cornerRadius: DSCornerRadius.md)
                .strokeBorder(
                    itemColor.opacity(item.type.isPlanned ? 0.5 : 0.2),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: item.type.isPlanned ? [5, 3] : []
                    )
                )
        }
        .opacity(item.type.isRest ? 0.6 : 1.0)
    }

    // MARK: - Helpers

    private var itemColor: Color {
        switch item.type {
        case .completed:
            return .green
        case .planned:
            return .orange
        case .rest:
            return .blue
        }
    }

    private var itemTypeLabel: String {
        switch item.type {
        case .completed:
            return String(localized: "Completed")
        case .planned:
            return String(localized: "Planned")
        case .rest:
            return String(localized: "Rest")
        }
    }
}
