//
//  Alarm.swift
//  AlarmaModern
//
//  Modern SwiftData model with Swift 6 features
//

import Foundation
import SwiftData

@Model
final class Alarm {
    @Attribute(.unique) var id: UUID
    var time: Date
    var isEnabled: Bool
    var sound: AlarmSound
    var loopSound: Bool
    var repeatDays: [Weekday]
    var createdAt: Date

    var group: Group?

    init(
        id: UUID = UUID(),
        time: Date = Date(),
        isEnabled: Bool = true,
        sound: AlarmSound = .default,
        loopSound: Bool = false,
        repeatDays: [Weekday] = [],
        createdAt: Date = Date(),
        group: Group? = nil
    ) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.sound = sound
        self.loopSound = loopSound
        self.repeatDays = repeatDays
        self.createdAt = createdAt
        self.group = group
    }

    /// Formatted time string
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    /// Display string for repeat pattern
    var repeatDisplayString: String {
        guard !repeatDays.isEmpty else { return "Never" }

        if repeatDays.count == 7 {
            return "Every day"
        }

        if repeatDays.count == 5 && !repeatDays.contains(.saturday) && !repeatDays.contains(.sunday) {
            return "Weekdays"
        }

        if repeatDays.count == 2 && repeatDays.contains(.saturday) && repeatDays.contains(.sunday) {
            return "Weekends"
        }

        return repeatDays.sorted().map { $0.shortName }.joined(separator: ", ")
    }

    /// Check if alarm should ring on a specific date
    func shouldRing(on date: Date) -> Bool {
        guard isEnabled else { return false }

        if repeatDays.isEmpty {
            return Calendar.current.isDate(time, inSameDayAs: date)
        }

        let weekday = Calendar.current.component(.weekday, from: date)
        guard let day = Weekday(rawValue: weekday) else { return false }
        return repeatDays.contains(day)
    }
}

// MARK: - Supporting Types

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

enum AlarmSound: String, Codable, CaseIterable, Identifiable {
    case `default` = "Default"
    case chime = "Chime"
    case bells = "Bells"
    case guitar = "Guitar"
    case piano = "Piano"
    case rock = "Rock"
    case silent = "Silent"

    var id: String { rawValue }

    var displayName: String { rawValue }
}
