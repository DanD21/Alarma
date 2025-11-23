//
//  GroupRepository.swift
//  AlarmaModern
//
//  Modern repository with Swift 6 concurrency and typed throws
//

import Foundation
import SwiftData

/// Errors that can occur in group operations
enum GroupRepositoryError: Error, LocalizedError {
    case groupNotFound
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case fetchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .groupNotFound:
            return "The requested group could not be found."
        case .saveFailed(let error):
            return "Failed to save group: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete group: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch groups: \(error.localizedDescription)"
        }
    }
}

/// Protocol defining group repository operations
protocol GroupRepositoryProtocol: Sendable {
    func fetchAll() throws -> [Group]
    func fetch(by id: UUID) throws -> Group?
    func save(_ group: Group) throws
    func delete(_ group: Group) throws
    func toggleEnabled(for group: Group) throws
}

/// Modern implementation using SwiftData
@ModelActor
actor GroupRepository: GroupRepositoryProtocol {
    func fetchAll() throws -> [Group] {
        let descriptor = FetchDescriptor<Group>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw GroupRepositoryError.fetchFailed(underlying: error)
        }
    }

    func fetch(by id: UUID) throws -> Group? {
        let predicate = #Predicate<Group> { group in
            group.id == id
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            throw GroupRepositoryError.fetchFailed(underlying: error)
        }
    }

    func save(_ group: Group) throws {
        do {
            modelContext.insert(group)
            try modelContext.save()
        } catch {
            throw GroupRepositoryError.saveFailed(underlying: error)
        }
    }

    func delete(_ group: Group) throws {
        do {
            modelContext.delete(group)
            try modelContext.save()
        } catch {
            throw GroupRepositoryError.deleteFailed(underlying: error)
        }
    }

    func toggleEnabled(for group: Group) throws {
        do {
            group.isEnabled.toggle()
            try modelContext.save()
        } catch {
            throw GroupRepositoryError.saveFailed(underlying: error)
        }
    }

    /// Get groups with active alarms
    func fetchGroupsWithActiveAlarms() throws -> [Group] {
        let predicate = #Predicate<Group> { group in
            group.isEnabled == true
        }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            throw GroupRepositoryError.fetchFailed(underlying: error)
        }
    }
}
