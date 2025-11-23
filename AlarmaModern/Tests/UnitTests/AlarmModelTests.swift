//
//  AlarmModelTests.swift
//  AlarmaModernTests
//
//  Unit tests for Alarm model logic
//

import Testing
import Foundation
@testable import AlarmaModern

@Suite("Alarm Model Tests")
struct AlarmModelTests {

    @Test("Repeat display string - never")
    func testRepeatDisplayStringNever() {
        // Given
        let alarm = Alarm(repeatDays: [])

        // Then
        #expect(alarm.repeatDisplayString == "Never")
    }

    @Test("Repeat display string - every day")
    func testRepeatDisplayStringEveryDay() {
        // Given
        let alarm = Alarm(repeatDays: Weekday.allCases)

        // Then
        #expect(alarm.repeatDisplayString == "Every day")
    }

    @Test("Repeat display string - weekdays")
    func testRepeatDisplayStringWeekdays() {
        // Given
        let alarm = Alarm(repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday])

        // Then
        #expect(alarm.repeatDisplayString == "Weekdays")
    }

    @Test("Repeat display string - weekends")
    func testRepeatDisplayStringWeekends() {
        // Given
        let alarm = Alarm(repeatDays: [.saturday, .sunday])

        // Then
        #expect(alarm.repeatDisplayString == "Weekends")
    }

    @Test("Repeat display string - specific days")
    func testRepeatDisplayStringSpecificDays() {
        // Given
        let alarm = Alarm(repeatDays: [.monday, .wednesday, .friday])

        // Then
        #expect(alarm.repeatDisplayString.contains("Mon"))
        #expect(alarm.repeatDisplayString.contains("Wed"))
        #expect(alarm.repeatDisplayString.contains("Fri"))
    }

    @Test("Should ring - disabled alarm")
    func testShouldNotRingWhenDisabled() {
        // Given
        let alarm = Alarm(time: Date(), isEnabled: false)

        // Then
        #expect(alarm.shouldRing(on: Date()) == false)
    }

    @Test("Should ring - one-time alarm on correct day")
    func testShouldRingOneTimeAlarmCorrectDay() {
        // Given
        let today = Date()
        let alarm = Alarm(time: today, isEnabled: true, repeatDays: [])

        // Then
        #expect(alarm.shouldRing(on: today) == true)
    }

    @Test("Should ring - recurring alarm on correct weekday")
    func testShouldRingRecurringAlarmCorrectDay() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let currentWeekday = Weekday(rawValue: weekday)!

        let alarm = Alarm(
            time: Date(),
            isEnabled: true,
            repeatDays: [currentWeekday]
        )

        // Then
        #expect(alarm.shouldRing(on: today) == true)
    }

    @Test("Should not ring - recurring alarm on wrong weekday")
    func testShouldNotRingRecurringAlarmWrongDay() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let currentWeekday = Weekday(rawValue: weekday)!

        // Get a different weekday
        let differentWeekday = Weekday.allCases.first { $0 != currentWeekday }!

        let alarm = Alarm(
            time: Date(),
            isEnabled: true,
            repeatDays: [differentWeekday]
        )

        // Then
        #expect(alarm.shouldRing(on: today) == false)
    }

    @Test("Time string formatting")
    func testTimeStringFormatting() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 1, day: 1, hour: 9, minute: 30)
        let time = calendar.date(from: components)!
        let alarm = Alarm(time: time)

        // Then
        #expect(alarm.timeString.contains("9"))
        #expect(alarm.timeString.contains("30"))
    }
}

@Suite("Weekday Tests")
struct WeekdayTests {

    @Test("Weekday names")
    func testWeekdayNames() {
        #expect(Weekday.monday.name == "Monday")
        #expect(Weekday.tuesday.name == "Tuesday")
        #expect(Weekday.wednesday.name == "Wednesday")
        #expect(Weekday.thursday.name == "Thursday")
        #expect(Weekday.friday.name == "Friday")
        #expect(Weekday.saturday.name == "Saturday")
        #expect(Weekday.sunday.name == "Sunday")
    }

    @Test("Weekday short names")
    func testWeekdayShortNames() {
        #expect(Weekday.monday.shortName == "Mon")
        #expect(Weekday.tuesday.shortName == "Tue")
        #expect(Weekday.wednesday.shortName == "Wed")
        #expect(Weekday.thursday.shortName == "Thu")
        #expect(Weekday.friday.shortName == "Fri")
        #expect(Weekday.saturday.shortName == "Sat")
        #expect(Weekday.sunday.shortName == "Sun")
    }

    @Test("All cases count")
    func testAllCasesCount() {
        #expect(Weekday.allCases.count == 7)
    }
}

@Suite("AlarmSound Tests")
struct AlarmSoundTests {

    @Test("All sound types exist")
    func testAllSoundTypes() {
        let sounds: [AlarmSound] = [.default, .chime, .bells, .guitar, .piano, .rock, .silent]
        #expect(sounds.count == 7)
        #expect(AlarmSound.allCases.count == 7)
    }

    @Test("Sound display names")
    func testSoundDisplayNames() {
        #expect(AlarmSound.default.displayName == "Default")
        #expect(AlarmSound.chime.displayName == "Chime")
        #expect(AlarmSound.bells.displayName == "Bells")
        #expect(AlarmSound.guitar.displayName == "Guitar")
        #expect(AlarmSound.piano.displayName == "Piano")
        #expect(AlarmSound.rock.displayName == "Rock")
        #expect(AlarmSound.silent.displayName == "Silent")
    }
}
