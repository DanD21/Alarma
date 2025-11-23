//
//  Group.swift
//  AlarmaModern
//
//  Modern SwiftData model with Swift 6 features
//

import Foundation
import SwiftData

@Model
final class Group {
    @Attribute(.unique) var id: UUID
    var name: String
    var isEnabled: Bool
    var interval: String? // Cron expression for recurring alarms
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Alarm.group)
    var alarms: [Alarm]

    init(
        id: UUID = UUID(),
        name: String,
        isEnabled: Bool = true,
        interval: String? = nil,
        createdAt: Date = Date(),
        alarms: [Alarm] = []
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.interval = interval
        self.createdAt = createdAt
        self.alarms = alarms
    }

    /// Number of enabled alarms in this group
    var enabledAlarmCount: Int {
        alarms.filter { $0.isEnabled }.count
    }

    /// Next alarm time for this group
    var nextAlarmTime: Date? {
        alarms
            .filter { $0.isEnabled }
            .compactMap { $0.time }
            .filter { $0 > Date() }
            .sorted()
            .first
    }
}

// MARK: - Computed Properties
extension Group {
    var alarmsCount: Int {
        alarms.count
    }

    var hasAlarms: Bool {
        !alarms.isEmpty
    }
}
