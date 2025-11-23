//
//  AlarmViewModel.swift
//  AlarmaModern
//
//  Modern ViewModel using @Observable and Swift 6 concurrency
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class AlarmViewModel {
    private let modelContext: ModelContext
    let group: Group

    var time: Date = Date()
    var sound: AlarmSound = .default
    var loopSound = false
    var selectedDays: Set<Weekday> = []
    var errorMessage: String?

    init(modelContext: ModelContext, group: Group) {
        self.modelContext = modelContext
        self.group = group
    }

    func createAlarm() async -> Bool {
        let alarm = Alarm(
            time: time,
            isEnabled: true,
            sound: sound,
            loopSound: loopSound,
            repeatDays: Array(selectedDays),
            group: group
        )

        modelContext.insert(alarm)

        do {
            try modelContext.save()
            return true
        } catch {
            errorMessage = "Failed to create alarm: \(error.localizedDescription)"
            return false
        }
    }

    func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    func isDaySelected(_ day: Weekday) -> Bool {
        selectedDays.contains(day)
    }

    var repeatDisplayString: String {
        guard !selectedDays.isEmpty else { return "Never" }

        if selectedDays.count == 7 {
            return "Every day"
        }

        let weekdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        if selectedDays == weekdays {
            return "Weekdays"
        }

        let weekends: Set<Weekday> = [.saturday, .sunday]
        if selectedDays == weekends {
            return "Weekends"
        }

        return selectedDays.sorted(by: { $0.rawValue < $1.rawValue })
            .map { $0.shortName }
            .joined(separator: ", ")
    }
}
