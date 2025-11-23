//
//  AlarmWidget.swift
//  AlarmaModern
//
//  Widget to show next upcoming alarm on home screen
//

import SwiftUI
import WidgetKit
import SwiftData

struct AlarmWidget: Widget {
    let kind: String = "AlarmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlarmWidgetProvider()) { entry in
            AlarmWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Alarm")
        .description("Shows your next upcoming alarm")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Provider
struct AlarmWidgetProvider: TimelineProvider {
    typealias Entry = AlarmWidgetEntry

    func placeholder(in context: Context) -> AlarmWidgetEntry {
        AlarmWidgetEntry(
            date: Date(),
            nextAlarm: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmWidgetEntry) -> Void) {
        let entry = AlarmWidgetEntry(date: Date(), nextAlarm: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmWidgetEntry>) -> Void) {
        Task {
            let nextAlarm = await fetchNextAlarm()
            let entry = AlarmWidgetEntry(date: Date(), nextAlarm: nextAlarm)

            // Update every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

            completion(timeline)
        }
    }

    private func fetchNextAlarm() async -> UpcomingAlarm? {
        do {
            let schema = Schema([Group.self, Alarm.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [config])

            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Alarm>(
                predicate: #Predicate { alarm in
                    alarm.isEnabled == true && alarm.time > Date()
                },
                sortBy: [SortDescriptor(\.time)]
            )

            let alarms = try context.fetch(descriptor)
            guard let nextAlarm = alarms.first else { return nil }

            return UpcomingAlarm(
                groupName: nextAlarm.group?.name ?? "Alarm",
                time: nextAlarm.time,
                sound: nextAlarm.sound.displayName
            )
        } catch {
            return nil
        }
    }
}

// MARK: - Entry
struct AlarmWidgetEntry: TimelineEntry {
    let date: Date
    let nextAlarm: UpcomingAlarm?
}

struct UpcomingAlarm {
    let groupName: String
    let time: Date
    let sound: String
}

// MARK: - Widget View
struct AlarmWidgetView: View {
    let entry: AlarmWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        if let alarm = entry.nextAlarm {
            switch family {
            case .systemSmall:
                SmallAlarmWidget(alarm: alarm)
            case .systemMedium:
                MediumAlarmWidget(alarm: alarm)
            default:
                SmallAlarmWidget(alarm: alarm)
            }
        } else {
            NoAlarmWidget()
        }
    }
}

struct SmallAlarmWidget: View {
    let alarm: UpcomingAlarm

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "alarm.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text(alarm.time, style: .time)
                .font(.title2)
                .fontWeight(.bold)

            Text(alarm.groupName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
    }
}

struct MediumAlarmWidget: View {
    let alarm: UpcomingAlarm

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange.gradient)

            VStack(alignment: .leading, spacing: 4) {
                Text("Next Alarm")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(alarm.time, style: .time)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(alarm.groupName)
                    .font(.headline)

                Text(alarm.sound)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}

struct NoAlarmWidget: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "alarm.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No upcoming alarms")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview(as: .systemSmall) {
    AlarmWidget()
} timeline: {
    AlarmWidgetEntry(
        date: Date(),
        nextAlarm: UpcomingAlarm(
            groupName: "Morning",
            time: Date().addingTimeInterval(3600),
            sound: "Chime"
        )
    )
    AlarmWidgetEntry(date: Date(), nextAlarm: nil)
}
