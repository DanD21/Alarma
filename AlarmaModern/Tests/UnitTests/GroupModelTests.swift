//
//  GroupModelTests.swift
//  AlarmaModernTests
//
//  Unit tests for Group model logic
//

import Testing
import Foundation
@testable import AlarmaModern

@Suite("Group Model Tests")
struct GroupModelTests {

    @Test("Group initialization with defaults")
    func testGroupInitializationWithDefaults() {
        // When
        let group = Group(name: "Test Group")

        // Then
        #expect(group.name == "Test Group")
        #expect(group.isEnabled == true)
        #expect(group.interval == nil)
        #expect(group.alarms.isEmpty)
    }

    @Test("Group initialization with custom values")
    func testGroupInitializationWithCustomValues() {
        // Given
        let alarm = Alarm(time: Date())

        // When
        let group = Group(
            name: "Work",
            isEnabled: false,
            interval: "0 9 * * 1-5",
            alarms: [alarm]
        )

        // Then
        #expect(group.name == "Work")
        #expect(group.isEnabled == false)
        #expect(group.interval == "0 9 * * 1-5")
        #expect(group.alarms.count == 1)
    }

    @Test("Alarms count")
    func testAlarmsCount() {
        // Given
        let group = Group(name: "Test")
        let alarm1 = Alarm(time: Date(), group: group)
        let alarm2 = Alarm(time: Date(), group: group)
        let alarm3 = Alarm(time: Date(), group: group)

        group.alarms = [alarm1, alarm2, alarm3]

        // Then
        #expect(group.alarmsCount == 3)
    }

    @Test("Has alarms - empty")
    func testHasAlarmsEmpty() {
        // Given
        let group = Group(name: "Test")

        // Then
        #expect(group.hasAlarms == false)
    }

    @Test("Has alarms - with alarms")
    func testHasAlarmsWithAlarms() {
        // Given
        let group = Group(name: "Test")
        let alarm = Alarm(time: Date(), group: group)
        group.alarms = [alarm]

        // Then
        #expect(group.hasAlarms == true)
    }

    @Test("Enabled alarm count")
    func testEnabledAlarmCount() {
        // Given
        let group = Group(name: "Test")
        let enabledAlarm1 = Alarm(time: Date(), isEnabled: true, group: group)
        let enabledAlarm2 = Alarm(time: Date(), isEnabled: true, group: group)
        let disabledAlarm = Alarm(time: Date(), isEnabled: false, group: group)

        group.alarms = [enabledAlarm1, enabledAlarm2, disabledAlarm]

        // Then
        #expect(group.enabledAlarmCount == 2)
    }

    @Test("Next alarm time - no alarms")
    func testNextAlarmTimeNoAlarms() {
        // Given
        let group = Group(name: "Test")

        // Then
        #expect(group.nextAlarmTime == nil)
    }

    @Test("Next alarm time - all disabled")
    func testNextAlarmTimeAllDisabled() {
        // Given
        let group = Group(name: "Test")
        let disabledAlarm = Alarm(
            time: Date().addingTimeInterval(3600),
            isEnabled: false,
            group: group
        )
        group.alarms = [disabledAlarm]

        // Then
        #expect(group.nextAlarmTime == nil)
    }

    @Test("Next alarm time - all in past")
    func testNextAlarmTimeAllInPast() {
        // Given
        let group = Group(name: "Test")
        let pastAlarm = Alarm(
            time: Date().addingTimeInterval(-3600),
            isEnabled: true,
            group: group
        )
        group.alarms = [pastAlarm]

        // Then
        #expect(group.nextAlarmTime == nil)
    }

    @Test("Next alarm time - returns earliest future alarm")
    func testNextAlarmTimeReturnsEarliestFuture() {
        // Given
        let group = Group(name: "Test")
        let now = Date()

        let alarm1 = Alarm(time: now.addingTimeInterval(7200), isEnabled: true, group: group)  // 2 hours
        let alarm2 = Alarm(time: now.addingTimeInterval(3600), isEnabled: true, group: group)  // 1 hour (earliest)
        let alarm3 = Alarm(time: now.addingTimeInterval(10800), isEnabled: true, group: group) // 3 hours
        let pastAlarm = Alarm(time: now.addingTimeInterval(-3600), isEnabled: true, group: group) // past
        let disabledFutureAlarm = Alarm(time: now.addingTimeInterval(1800), isEnabled: false, group: group) // disabled

        group.alarms = [alarm1, alarm2, alarm3, pastAlarm, disabledFutureAlarm]

        // Then
        let nextTime = group.nextAlarmTime
        #expect(nextTime != nil)

        // Should be alarm2 (1 hour from now)
        let timeDifference = abs(nextTime!.timeIntervalSince(alarm2.time))
        #expect(timeDifference < 1) // Within 1 second tolerance
    }

    @Test("Group unique ID")
    func testGroupUniqueID() {
        // Given
        let group1 = Group(name: "Group 1")
        let group2 = Group(name: "Group 2")

        // Then
        #expect(group1.id != group2.id)
    }
}
