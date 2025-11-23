//
//  CreateAlarmIntent.swift
//  AlarmaModern
//
//  Siri Shortcuts integration for creating alarms
//

import AppIntents
import SwiftData

struct CreateAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Alarm"
    static var description = IntentDescription("Create a new alarm in Alarma")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Time")
    var time: Date

    @Parameter(title: "Group Name", default: "Quick Alarm")
    var groupName: String

    @Parameter(title: "Repeat Days", default: [])
    var repeatDays: [String]

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Create model container
        let schema = Schema([Group.self, Alarm.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Find or create group
        let groupDescriptor = FetchDescriptor<Group>(
            predicate: #Predicate { group in
                group.name == groupName
            }
        )

        let groups = try context.fetch(groupDescriptor)
        let group: Group
        if let existingGroup = groups.first {
            group = existingGroup
        } else {
            group = Group(name: groupName)
            context.insert(group)
        }

        // Convert repeat days
        let weekdays = repeatDays.compactMap { day -> Weekday? in
            switch day.lowercased() {
            case "sunday": return .sunday
            case "monday": return .monday
            case "tuesday": return .tuesday
            case "wednesday": return .wednesday
            case "thursday": return .thursday
            case "friday": return .friday
            case "saturday": return .saturday
            default: return nil
            }
        }

        // Create alarm
        let alarm = Alarm(
            time: time,
            isEnabled: true,
            repeatDays: weekdays,
            group: group
        )

        context.insert(alarm)
        try context.save()

        // Schedule notification
        try await NotificationService.shared.scheduleNotification(for: alarm)

        let timeString = time.formatted(date: .omitted, time: .shortened)
        let message = "Alarm created for \(timeString) in \(groupName)"

        return .result(dialog: IntentDialog(message))
    }
}

struct ToggleAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Alarm"
    static var description = IntentDescription("Enable or disable an alarm")

    @Parameter(title: "Group Name")
    var groupName: String

    @Parameter(title: "Enable", default: true)
    var enable: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let schema = Schema([Group.self, Alarm.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Find group
        let groupDescriptor = FetchDescriptor<Group>(
            predicate: #Predicate { group in
                group.name == groupName
            }
        )

        let groups = try context.fetch(groupDescriptor)
        guard let group = groups.first else {
            throw IntentError.message("Group '\(groupName)' not found")
        }

        // Toggle all alarms in group
        for alarm in group.alarms {
            alarm.isEnabled = enable

            if enable {
                try await NotificationService.shared.scheduleNotification(for: alarm)
            } else {
                NotificationService.shared.cancelNotification(for: alarm)
            }
        }

        try context.save()

        let message = enable ? "Enabled all alarms in \(groupName)" : "Disabled all alarms in \(groupName)"
        return .result(dialog: IntentDialog(message))
    }
}

struct GetNextAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Next Alarm"
    static var description = IntentDescription("Get information about the next upcoming alarm")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let schema = Schema([Group.self, Alarm.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let now = Date()
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate { alarm in
                alarm.isEnabled == true && alarm.time > now
            },
            sortBy: [SortDescriptor(\.time)]
        )

        let alarms = try context.fetch(descriptor)

        guard let nextAlarm = alarms.first else {
            return .result(
                value: "No upcoming alarms",
                dialog: IntentDialog("You have no upcoming alarms")
            )
        }

        let timeString = nextAlarm.time.formatted(date: .omitted, time: .shortened)
        let groupName = nextAlarm.group?.name ?? "Alarm"
        let message = "Your next alarm is at \(timeString) in \(groupName)"

        return .result(value: message, dialog: IntentDialog(message))
    }
}

// MARK: - App Shortcuts Provider

struct AlarmaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetNextAlarmIntent(),
            phrases: [
                "Show my next \(.applicationName) alarm",
                "When is my next alarm in \(.applicationName)",
                "Next alarm in \(.applicationName)"
            ],
            shortTitle: "Next Alarm",
            systemImageName: "alarm"
        )

        AppShortcut(
            intent: CreateAlarmIntent(),
            phrases: [
                "Create an alarm in \(.applicationName)",
                "Set a new alarm in \(.applicationName)",
                "Add alarm to \(.applicationName)"
            ],
            shortTitle: "Create Alarm",
            systemImageName: "plus.circle"
        )
    }
}
