//
//  AlarmRepositoryTests.swift
//  AlarmaModernTests
//
//  Unit tests for AlarmRepository using Swift Testing framework
//

import Testing
import Foundation
import SwiftData
@testable import AlarmaModern

@Suite("Alarm Repository Tests")
struct AlarmRepositoryTests {
    let modelContainer: ModelContainer
    let alarmRepository: AlarmRepository
    let groupRepository: GroupRepository
    let testGroup: Group

    init() throws {
        let schema = Schema([Group.self, Alarm.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        alarmRepository = AlarmRepository(modelContainer: modelContainer)
        groupRepository = GroupRepository(modelContainer: modelContainer)

        // Create test group
        testGroup = Group(name: "Test Group")
        try await groupRepository.save(testGroup)
    }

    @Test("Create and fetch alarm")
    func testCreateAndFetchAlarm() async throws {
        // Given
        let alarm = Alarm(
            time: Date(),
            sound: .chime,
            group: testGroup
        )

        // When
        try await alarmRepository.save(alarm)
        let fetchedAlarms = try await alarmRepository.fetchAll()

        // Then
        #expect(fetchedAlarms.count == 1)
        #expect(fetchedAlarms.first?.sound == .chime)
        #expect(fetchedAlarms.first?.isEnabled == true)
    }

    @Test("Fetch alarm by ID")
    func testFetchAlarmByID() async throws {
        // Given
        let alarm = Alarm(time: Date(), group: testGroup)
        try await alarmRepository.save(alarm)

        // When
        let fetchedAlarm = try await alarmRepository.fetch(by: alarm.id)

        // Then
        #expect(fetchedAlarm != nil)
        #expect(fetchedAlarm?.id == alarm.id)
    }

    @Test("Delete alarm")
    func testDeleteAlarm() async throws {
        // Given
        let alarm = Alarm(time: Date(), group: testGroup)
        try await alarmRepository.save(alarm)

        // When
        try await alarmRepository.delete(alarm)
        let fetchedAlarms = try await alarmRepository.fetchAll()

        // Then
        #expect(fetchedAlarms.isEmpty)
    }

    @Test("Toggle alarm enabled status")
    func testToggleAlarmEnabled() async throws {
        // Given
        let alarm = Alarm(time: Date(), isEnabled: true, group: testGroup)
        try await alarmRepository.save(alarm)

        // When
        try await alarmRepository.toggleEnabled(for: alarm)
        let fetchedAlarm = try await alarmRepository.fetch(by: alarm.id)

        // Then
        #expect(fetchedAlarm?.isEnabled == false)
    }

    @Test("Fetch alarms for specific group")
    func testFetchAlarmsForGroup() async throws {
        // Given
        let group1 = Group(name: "Group 1")
        let group2 = Group(name: "Group 2")
        try await groupRepository.save(group1)
        try await groupRepository.save(group2)

        let alarm1 = Alarm(time: Date(), group: group1)
        let alarm2 = Alarm(time: Date(), group: group1)
        let alarm3 = Alarm(time: Date(), group: group2)

        try await alarmRepository.save(alarm1)
        try await alarmRepository.save(alarm2)
        try await alarmRepository.save(alarm3)

        // When
        let group1Alarms = try await alarmRepository.fetchAlarms(for: group1)

        // Then
        #expect(group1Alarms.count == 2)
    }

    @Test("Fetch upcoming alarms")
    func testFetchUpcomingAlarms() async throws {
        // Given
        let pastAlarm = Alarm(
            time: Date().addingTimeInterval(-3600), // 1 hour ago
            isEnabled: true,
            group: testGroup
        )
        let futureAlarm1 = Alarm(
            time: Date().addingTimeInterval(3600), // 1 hour from now
            isEnabled: true,
            group: testGroup
        )
        let futureAlarm2 = Alarm(
            time: Date().addingTimeInterval(7200), // 2 hours from now
            isEnabled: true,
            group: testGroup
        )
        let disabledFutureAlarm = Alarm(
            time: Date().addingTimeInterval(10800), // 3 hours from now
            isEnabled: false,
            group: testGroup
        )

        try await alarmRepository.save(pastAlarm)
        try await alarmRepository.save(futureAlarm1)
        try await alarmRepository.save(futureAlarm2)
        try await alarmRepository.save(disabledFutureAlarm)

        // When
        let upcomingAlarms = try await alarmRepository.fetchUpcomingAlarms()

        // Then
        #expect(upcomingAlarms.count == 2)
        #expect(upcomingAlarms[0].time < upcomingAlarms[1].time) // Sorted by time
    }

    @Test("Alarms sorted by time")
    func testAlarmsSortedByTime() async throws {
        // Given
        let time1 = Date().addingTimeInterval(3600)
        let time2 = Date().addingTimeInterval(7200)
        let time3 = Date().addingTimeInterval(1800)

        let alarm1 = Alarm(time: time1, group: testGroup)
        let alarm2 = Alarm(time: time2, group: testGroup)
        let alarm3 = Alarm(time: time3, group: testGroup)

        try await alarmRepository.save(alarm1)
        try await alarmRepository.save(alarm2)
        try await alarmRepository.save(alarm3)

        // When
        let fetchedAlarms = try await alarmRepository.fetchAll()

        // Then
        #expect(fetchedAlarms.count == 3)
        #expect(fetchedAlarms[0].time == time3) // Earliest
        #expect(fetchedAlarms[1].time == time1)
        #expect(fetchedAlarms[2].time == time2) // Latest
    }
}
