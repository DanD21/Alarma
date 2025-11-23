//
//  GroupRepositoryTests.swift
//  AlarmaModernTests
//
//  Unit tests for GroupRepository using Swift Testing framework
//

import Testing
import Foundation
import SwiftData
@testable import AlarmaModern

@Suite("Group Repository Tests")
struct GroupRepositoryTests {
    let modelContainer: ModelContainer
    let repository: GroupRepository

    init() throws {
        let schema = Schema([Group.self, Alarm.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        repository = GroupRepository(modelContainer: modelContainer)
    }

    @Test("Create and fetch group")
    func testCreateAndFetchGroup() async throws {
        // Given
        let group = Group(name: "Morning Alarms")

        // When
        try await repository.save(group)
        let fetchedGroups = try await repository.fetchAll()

        // Then
        #expect(fetchedGroups.count == 1)
        #expect(fetchedGroups.first?.name == "Morning Alarms")
        #expect(fetchedGroups.first?.isEnabled == true)
    }

    @Test("Fetch group by ID")
    func testFetchGroupByID() async throws {
        // Given
        let group = Group(name: "Work Alarms")
        try await repository.save(group)

        // When
        let fetchedGroup = try await repository.fetch(by: group.id)

        // Then
        #expect(fetchedGroup != nil)
        #expect(fetchedGroup?.name == "Work Alarms")
        #expect(fetchedGroup?.id == group.id)
    }

    @Test("Delete group")
    func testDeleteGroup() async throws {
        // Given
        let group = Group(name: "To Delete")
        try await repository.save(group)

        // When
        try await repository.delete(group)
        let fetchedGroups = try await repository.fetchAll()

        // Then
        #expect(fetchedGroups.isEmpty)
    }

    @Test("Toggle group enabled status")
    func testToggleGroupEnabled() async throws {
        // Given
        let group = Group(name: "Toggle Test", isEnabled: true)
        try await repository.save(group)

        // When
        try await repository.toggleEnabled(for: group)
        let fetchedGroup = try await repository.fetch(by: group.id)

        // Then
        #expect(fetchedGroup?.isEnabled == false)

        // Toggle again
        try await repository.toggleEnabled(for: group)
        let fetchedGroupAgain = try await repository.fetch(by: group.id)
        #expect(fetchedGroupAgain?.isEnabled == true)
    }

    @Test("Fetch groups with active alarms")
    func testFetchGroupsWithActiveAlarms() async throws {
        // Given
        let activeGroup = Group(name: "Active", isEnabled: true)
        let inactiveGroup = Group(name: "Inactive", isEnabled: false)

        try await repository.save(activeGroup)
        try await repository.save(inactiveGroup)

        // When
        let activeGroups = try await repository.fetchGroupsWithActiveAlarms()

        // Then
        #expect(activeGroups.count == 1)
        #expect(activeGroups.first?.name == "Active")
    }

    @Test("Multiple groups sorted by creation date")
    func testMultipleGroupsSorting() async throws {
        // Given
        let group1 = Group(name: "First")
        let group2 = Group(name: "Second")
        let group3 = Group(name: "Third")

        // When
        try await repository.save(group1)
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        try await repository.save(group2)
        try await Task.sleep(nanoseconds: 100_000_000)
        try await repository.save(group3)

        let fetchedGroups = try await repository.fetchAll()

        // Then
        #expect(fetchedGroups.count == 3)
        // Should be sorted by creation date in reverse (newest first)
        #expect(fetchedGroups[0].name == "Third")
        #expect(fetchedGroups[1].name == "Second")
        #expect(fetchedGroups[2].name == "First")
    }

    @Test("Fetch non-existent group returns nil")
    func testFetchNonExistentGroup() async throws {
        // When
        let fetchedGroup = try await repository.fetch(by: UUID())

        // Then
        #expect(fetchedGroup == nil)
    }
}
