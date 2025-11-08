//
//  AntrainWidget.swift
//  AntrainWidget
//
//  Antrain Home Screen Widget
//  Shows "Start Workout" button and today's program info
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    // Simple entry without configuration for now
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), workoutCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), workoutCount: 5)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Update widget every hour
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, workoutCount: getWeekWorkoutCount())
        
        // Refresh in 1 hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    // Get this week's workout count (read from shared data)
    private func getWeekWorkoutCount() -> Int {
        return WidgetDataHelper.shared.getWorkoutCount()
    }
}

// MARK: - Timeline Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let workoutCount: Int
}

// MARK: - Widget Views

struct AntrainWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        Link(destination: URL(string: "antrain://start-workout")!) {
            widgetContent
        }
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (2x2)

struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // App icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white)
            
            Text("Antrain")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer()
            
            // Start button
            VStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.caption)
                Text("Start")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Medium Widget (4x2)

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                    Text("Antrain")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    if entry.workoutCount == 0 {
                        Text("Let's start!")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(entry.workoutCount)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(entry.workoutCount == 1 ? "workout" : "workouts")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            
            Spacer()
            
            // Right: Button
            VStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                
                Text("Start\nWorkout")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
            }
            .frame(width: 80)
            .padding()
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Large Widget (4x4)

struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "dumbbell.fill")
                    .font(.title2)
                Text("Antrain")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
            
            // Stats
            HStack(spacing: 12) {
                StatBox(value: "\(entry.workoutCount)", label: "This Week")
                StatBox(value: "💪", label: "Keep Going")
            }
            
            Spacer()
            
            // Start button
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                    
                    Text("Start Workout")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                Spacer()
            }
            .padding()
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Helper Views

struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Widget Configuration

struct AntrainWidget: Widget {
    let kind: String = "AntrainWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AntrainWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        // Gradient background
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
            } else {
                AntrainWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Antrain")
        .description("Quick access to start your workout")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    AntrainWidget()
} timeline: {
    SimpleEntry(date: .now, workoutCount: 3)
    SimpleEntry(date: .now, workoutCount: 5)
}

#Preview(as: .systemMedium) {
    AntrainWidget()
} timeline: {
    SimpleEntry(date: .now, workoutCount: 3)
}

#Preview(as: .systemLarge) {
    AntrainWidget()
} timeline: {
    SimpleEntry(date: .now, workoutCount: 7)
}

