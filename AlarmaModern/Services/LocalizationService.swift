//
//  LocalizationService.swift
//  AlarmaModern
//
//  Helper for accessing localized strings
//

import Foundation

struct L10n {
    // MARK: - Common
    static let save = NSLocalizedString("common.save", comment: "")
    static let cancel = NSLocalizedString("common.cancel", comment: "")
    static let delete = NSLocalizedString("common.delete", comment: "")
    static let edit = NSLocalizedString("common.edit", comment: "")
    static let done = NSLocalizedString("common.done", comment: "")
    static let ok = NSLocalizedString("common.ok", comment: "")
    static let error = NSLocalizedString("common.error", comment: "")
    static let retry = NSLocalizedString("common.retry", comment: "")
    static let loading = NSLocalizedString("common.loading", comment: "")

    // MARK: - Alarms
    struct Alarms {
        static let title = NSLocalizedString("alarms.title", comment: "")
        static let new = NSLocalizedString("alarms.new", comment: "")
        static let add = NSLocalizedString("alarms.add", comment: "")
        static let none = NSLocalizedString("alarms.none", comment: "")
        static let time = NSLocalizedString("alarms.time", comment: "")
        static let enabled = NSLocalizedString("alarms.enabled", comment: "")
        static let disabled = NSLocalizedString("alarms.disabled", comment: "")

        static func noneDescription(groupName: String) -> String {
            String(format: NSLocalizedString("alarms.none.description", comment: ""), groupName)
        }
    }

    // MARK: - Groups
    struct Groups {
        static let title = NSLocalizedString("groups.title", comment: "")
        static let new = NSLocalizedString("groups.new", comment: "")
        static let add = NSLocalizedString("groups.add", comment: "")
        static let none = NSLocalizedString("groups.none", comment: "")
        static let noneDescription = NSLocalizedString("groups.none.description", comment: "")
        static let name = NSLocalizedString("groups.name", comment: "")
        static let select = NSLocalizedString("groups.select", comment: "")
        static let selectDescription = NSLocalizedString("groups.select.description", comment: "")

        static func alarmsCount(_ count: Int) -> String {
            String(format: NSLocalizedString("groups.alarms.count", comment: ""), count)
        }
    }

    // MARK: - Time & Repeat
    struct Time {
        static let label = NSLocalizedString("time.label", comment: "")
    }

    struct Repeat {
        static let label = NSLocalizedString("repeat.label", comment: "")
        static let never = NSLocalizedString("repeat.never", comment: "")
        static let everyday = NSLocalizedString("repeat.everyday", comment: "")
        static let weekdays = NSLocalizedString("repeat.weekdays", comment: "")
        static let weekends = NSLocalizedString("repeat.weekends", comment: "")
    }

    // MARK: - Weekdays
    struct Weekdays {
        static let sunday = NSLocalizedString("weekday.sunday", comment: "")
        static let monday = NSLocalizedString("weekday.monday", comment: "")
        static let tuesday = NSLocalizedString("weekday.tuesday", comment: "")
        static let wednesday = NSLocalizedString("weekday.wednesday", comment: "")
        static let thursday = NSLocalizedString("weekday.thursday", comment: "")
        static let friday = NSLocalizedString("weekday.friday", comment: "")
        static let saturday = NSLocalizedString("weekday.saturday", comment: "")

        struct Short {
            static let sun = NSLocalizedString("weekday.short.sun", comment: "")
            static let mon = NSLocalizedString("weekday.short.mon", comment: "")
            static let tue = NSLocalizedString("weekday.short.tue", comment: "")
            static let wed = NSLocalizedString("weekday.short.wed", comment: "")
            static let thu = NSLocalizedString("weekday.short.thu", comment: "")
            static let fri = NSLocalizedString("weekday.short.fri", comment: "")
            static let sat = NSLocalizedString("weekday.short.sat", comment: "")
        }
    }

    // MARK: - Sounds
    struct Sounds {
        static let label = NSLocalizedString("sound.label", comment: "")
        static let loop = NSLocalizedString("sound.loop", comment: "")
        static let `default` = NSLocalizedString("sound.default", comment: "")
        static let chime = NSLocalizedString("sound.chime", comment: "")
        static let bells = NSLocalizedString("sound.bells", comment: "")
        static let guitar = NSLocalizedString("sound.guitar", comment: "")
        static let piano = NSLocalizedString("sound.piano", comment: "")
        static let rock = NSLocalizedString("sound.rock", comment: "")
        static let silent = NSLocalizedString("sound.silent", comment: "")
    }

    // MARK: - Errors
    struct Errors {
        static let alarmCreate = NSLocalizedString("error.alarm.create", comment: "")
        static let alarmUpdate = NSLocalizedString("error.alarm.update", comment: "")
        static let alarmDelete = NSLocalizedString("error.alarm.delete", comment: "")
        static let groupCreate = NSLocalizedString("error.group.create", comment: "")
        static let groupUpdate = NSLocalizedString("error.group.update", comment: "")
        static let groupDelete = NSLocalizedString("error.group.delete", comment: "")
        static let notificationSchedule = NSLocalizedString("error.notification.schedule", comment: "")
        static let unknown = NSLocalizedString("error.unknown", comment: "")
        static let nameEmpty = NSLocalizedString("error.name.empty", comment: "")
    }

    // MARK: - Success
    struct Success {
        static let alarmCreated = NSLocalizedString("success.alarm.created", comment: "")
        static let alarmUpdated = NSLocalizedString("success.alarm.updated", comment: "")
        static let alarmDeleted = NSLocalizedString("success.alarm.deleted", comment: "")
        static let groupCreated = NSLocalizedString("success.group.created", comment: "")
    }
}

// MARK: - Weekday Extension for Localization

extension Weekday {
    var localizedName: String {
        switch self {
        case .sunday: return L10n.Weekdays.sunday
        case .monday: return L10n.Weekdays.monday
        case .tuesday: return L10n.Weekdays.tuesday
        case .wednesday: return L10n.Weekdays.wednesday
        case .thursday: return L10n.Weekdays.thursday
        case .friday: return L10n.Weekdays.friday
        case .saturday: return L10n.Weekdays.saturday
        }
    }

    var localizedShortName: String {
        switch self {
        case .sunday: return L10n.Weekdays.Short.sun
        case .monday: return L10n.Weekdays.Short.mon
        case .tuesday: return L10n.Weekdays.Short.tue
        case .wednesday: return L10n.Weekdays.Short.wed
        case .thursday: return L10n.Weekdays.Short.thu
        case .friday: return L10n.Weekdays.Short.fri
        case .saturday: return L10n.Weekdays.Short.sat
        }
    }
}

// MARK: - AlarmSound Extension for Localization

extension AlarmSound {
    var localizedDisplayName: String {
        switch self {
        case .default: return L10n.Sounds.default
        case .chime: return L10n.Sounds.chime
        case .bells: return L10n.Sounds.bells
        case .guitar: return L10n.Sounds.guitar
        case .piano: return L10n.Sounds.piano
        case .rock: return L10n.Sounds.rock
        case .silent: return L10n.Sounds.silent
        }
    }
}
