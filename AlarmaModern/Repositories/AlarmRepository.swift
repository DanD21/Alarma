//
//  AlarmRepository.swift
//  AlarmaModern
//
//  Modern repository with Swift 6 concurrency
//

import Foundation
import SwiftData

/// Errors that can occur in alarm operations
enum AlarmRepositoryError: Error, LocalizedError {
    case alarmNotFound
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case fetchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .alarmNotFound:
            return "The requested alarm could not be found."
        case .saveFailed(let error):
            return "Failed to save alarm: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete alarm: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch alarms: \(error.localizedDescription)"
        }
    }
}

/// Protocol defining alarm repository operations
protocol AlarmRepositoryProtocol: Sendable {
    func fetchAll() throws -> [Alarm]
    func fetch(by id: UUID) throws -> Alarm?
    func fetchAlarms(for group: Group) throws -> [Alarm]
    func save(_ alarm: Alarm) throws
    func delete(_ alarm: Alarm) throws
    func toggleEnabled(for alarm: Alarm) throws
}

/// Modern implementation using SwiftData
@ModelActor
actor AlarmRepository: AlarmRepositoryProtocol {
    func fetchAll() throws -> [Alarm] {
        let descriptor = FetchDescriptor<Alarm>(
            sortBy: [SortDescriptor(\.time)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw AlarmRepositoryError.fetchFailed(underlying: error)
        }
    }

    func fetch(by id: UUID) throws -> Alarm? {
        let predicate = #Predicate<Alarm> { alarm in
            alarm.id == id
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            throw AlarmRepositoryError.fetchFailed(underlying: error)
        }
    }

    func fetchAlarms(for group: Group) throws -> [Alarm] {
        let groupID = group.id
        let predicate = #Predicate<Alarm> { alarm in
            alarm.group?.id == groupID
        }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.time)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw AlarmRepositoryError.fetchFailed(underlying: error)
        }
    }

    func save(_ alarm: Alarm) throws {
        do {
            modelContext.insert(alarm)
            try modelContext.save()
        } catch {
            throw AlarmRepositoryError.saveFailed(underlying: error)
        }
    }

    func delete(_ alarm: Alarm) throws {
        do {
            modelContext.delete(alarm)
            try modelContext.save()
        } catch {
            throw AlarmRepositoryError.deleteFailed(underlying: error)
        }
    }

    func toggleEnabled(for alarm: Alarm) throws {
        do {
            alarm.isEnabled.toggle()
            try modelContext.save()
        } catch {
            throw AlarmRepositoryError.saveFailed(underlying: error)
        }
    }

    /// Fetch upcoming enabled alarms
    func fetchUpcomingAlarms(limit: Int = 10) throws -> [Alarm] {
        let now = Date()
        let predicate = #Predicate<Alarm> { alarm in
            alarm.isEnabled == true && alarm.time > now
        }
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.time)]
        )
        descriptor.fetchLimit = limit

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw AlarmRepositoryError.fetchFailed(underlying: error)
        }
    }
}
