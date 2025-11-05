import SwiftUI

/// Workout calendar view component
/// Displays workouts in a monthly calendar grid
@MainActor
struct DSCalendarView<DayContent: View>: View {
    let items: [Workout]
    let indicatorColor: Color
    let dayContent: ([Workout]) -> DayContent

    @State private var currentMonth = Date()
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.veryShortWeekdaySymbols
    }

    init(
        items: [Workout],
        indicatorColor: Color = DSColors.primary,
        @ViewBuilder dayContent: @escaping ([Workout]) -> DayContent
    ) {
        self.items = items
        self.indicatorColor = indicatorColor
        self.dayContent = dayContent
    }

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            // Month header with navigation
            monthHeader

            // Days of week header
            daysOfWeekHeader

            // Calendar grid
            calendarGrid

            // Selected day content
            if let selectedDate = selectedDate {
                selectedDaySection(for: selectedDate)
            }
        }
        .onAppear {
            // Select today by default
            selectedDate = Date()
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(DSColors.primary)
            }

            Spacer()

            Text(monthYearString(from: currentMonth))
                .font(DSTypography.title2)
                .fontWeight(.semibold)

            Spacer()

            Button {
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(DSColors.primary)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
    }

    // MARK: - Days of Week Header

    private var daysOfWeekHeader: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(DSTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DSColors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = daysInMonth(for: currentMonth)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    // Empty cell for padding
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
    }

    // MARK: - Day Cell

    private func dayCell(for date: Date) -> some View {
        let itemsOnDay = itemsCount(on: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate ?? Date())
        let isToday = calendar.isDateInToday(date)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(DSTypography.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : DSColors.textPrimary)

                // Item indicator dots
                if itemsOnDay > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<min(itemsOnDay, 3), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? .white : indicatorColor)
                                .frame(width: 4, height: 4)
                        }
                    }
                } else {
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                    .fill(isSelected ? DSColors.primary : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSCornerRadius.sm)
                    .stroke(isToday && !isSelected ? DSColors.primary : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selected Day Section

    private func selectedDaySection(for date: Date) -> some View {
        let dayItems = items.filter { item in
            calendar.isDate(item.date, inSameDayAs: date)
        }

        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Divider()
                .padding(.vertical, DSSpacing.xs)

            HStack {
                Text(dateString(from: date))
                    .font(DSTypography.title3)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(dayItems.count) item\(dayItems.count == 1 ? "" : "s")")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            dayContent(dayItems)
        }
    }

    // MARK: - Helper Functions

    private func daysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let paddingDays = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: paddingDays)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    private func itemsCount(on date: Date) -> Int {
        items.filter { item in
            calendar.isDate(item.date, inSameDayAs: date)
        }.count
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let today = Date()

    let sampleWorkouts: [Workout] = [
        Workout(date: today, type: .lifting, duration: 3600, notes: "Chest day"),
        Workout(date: calendar.date(byAdding: .day, value: -1, to: today)!, type: .cardio, duration: 1800),
        Workout(date: calendar.date(byAdding: .day, value: -3, to: today)!, type: .metcon, duration: 1200),
        Workout(date: calendar.date(byAdding: .day, value: -3, to: today)!, type: .lifting, duration: 3900),
        Workout(date: calendar.date(byAdding: .day, value: -7, to: today)!, type: .lifting, duration: 4200)
    ]

    NavigationStack {
        ScrollView {
            DSCalendarView(items: sampleWorkouts) { workouts in
                if workouts.isEmpty {
                    VStack(spacing: DSSpacing.sm) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.title)
                            .foregroundStyle(DSColors.textSecondary)

                        Text("No workouts")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.lg)
                } else {
                    LazyVStack(spacing: DSSpacing.xs) {
                        ForEach(workouts) { workout in
                            HStack {
                                Image(systemName: "dumbbell.fill")
                                    .foregroundStyle(DSColors.primary)
                                Text(workout.type.rawValue.capitalized)
                                Spacer()
                            }
                            .padding(DSSpacing.sm)
                            .background(DSColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DSCornerRadius.md))
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
        .navigationTitle("Calendar")
    }
}
