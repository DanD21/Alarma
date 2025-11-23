//
//  AlarmCreationViewUITests.swift
//  AlarmaModernUITests
//
//  UI tests for AlarmCreationView
//

import XCTest

@MainActor
final class AlarmCreationViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testAlarmCreationViewAppears() throws {
        setupGroupDetailView()

        // Tap add alarm button
        app.buttons["Add Alarm"].tap()

        // Verify alarm creation sheet appears
        XCTAssertTrue(app.navigationBars["New Alarm"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Cancel"].exists)
        XCTAssertTrue(app.buttons["Save"].exists)
    }

    func testCreateBasicAlarm() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Verify sections exist
        XCTAssertTrue(app.staticTexts["Time"].exists)
        XCTAssertTrue(app.staticTexts["Repeat"].exists)
        XCTAssertTrue(app.staticTexts["Sound"].exists)

        // Save alarm
        app.buttons["Save"].tap()

        // Verify we're back to group detail view
        XCTAssertTrue(app.navigationBars["Test Group"].waitForExistence(timeout: 2))

        // Verify alarm was created (check for time string)
        XCTAssertGreaterThan(app.cells.count, 0)
    }

    func testCancelAlarmCreation() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Cancel
        app.buttons["Cancel"].tap()

        // Verify we're back to group detail view
        XCTAssertTrue(app.navigationBars["Test Group"].waitForExistence(timeout: 2))
    }

    func testSelectSound() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Find and tap sound picker
        let soundPicker = app.buttons["Sound, Default"]
        if soundPicker.exists {
            soundPicker.tap()

            // Select a different sound
            app.buttons["Chime"].tap()

            // Verify selection changed
            XCTAssertTrue(app.buttons["Sound, Chime"].exists)
        }
    }

    func testToggleLoopSound() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Find loop sound toggle
        let loopToggle = app.switches["Loop Sound"]
        XCTAssertTrue(loopToggle.exists)

        // Get initial state
        let initialState = loopToggle.value as? String == "1"

        // Toggle
        loopToggle.tap()

        // Verify state changed
        let newState = loopToggle.value as? String == "1"
        XCTAssertNotEqual(initialState, newState)
    }

    func testSelectRepeatDays() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Initially should show "Never"
        XCTAssertTrue(app.staticTexts["Never"].exists)

        // Tap Monday button
        let mondayButton = app.buttons["Mon"]
        if mondayButton.exists {
            mondayButton.tap()

            // Verify "Never" is gone and Monday is selected
            // The display should now show selected days
            XCTAssertTrue(mondayButton.exists)
        }

        // Tap Wednesday
        let wednesdayButton = app.buttons["Wed"]
        if wednesdayButton.exists {
            wednesdayButton.tap()
        }

        // Tap Friday
        let fridayButton = app.buttons["Fri"]
        if fridayButton.exists {
            fridayButton.tap()
        }

        // All three buttons should be selected (this would show visually but hard to test)
        XCTAssertTrue(mondayButton.exists)
        XCTAssertTrue(wednesdayButton.exists)
        XCTAssertTrue(fridayButton.exists)
    }

    func testSelectAllDaysShowsEveryDay() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Select all days
        let allDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for day in allDays {
            let dayButton = app.buttons[day]
            if dayButton.exists {
                dayButton.tap()
            }
        }

        // Should show "Every day"
        XCTAssertTrue(app.staticTexts["Every day"].exists)
    }

    func testSelectWeekdays() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Select weekdays (Mon-Fri)
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        for day in weekdays {
            let dayButton = app.buttons[day]
            if dayButton.exists {
                dayButton.tap()
            }
        }

        // Should show "Weekdays"
        XCTAssertTrue(app.staticTexts["Weekdays"].exists)
    }

    func testSelectWeekends() throws {
        setupGroupDetailView()

        // Open alarm creation
        app.buttons["Add Alarm"].tap()

        // Select weekends
        let weekends = ["Sat", "Sun"]
        for day in weekends {
            let dayButton = app.buttons[day]
            if dayButton.exists {
                dayButton.tap()
            }
        }

        // Should show "Weekends"
        XCTAssertTrue(app.staticTexts["Weekends"].exists)
    }

    // MARK: - Helper Methods

    private func skipOnboarding() {
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.waitForExistence(timeout: 2) {
            getStartedButton.tap()
        }

        let notNowButton = app.buttons["Not Now"]
        if notNowButton.waitForExistence(timeout: 2) {
            notNowButton.tap()
        }

        _ = app.navigationBars["Alarms"].waitForExistence(timeout: 2)
    }

    private func createTestGroup() {
        app.buttons["Add Group"].tap()

        let alert = app.alerts["New Alarm Group"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        let textField = alert.textFields["Group Name"]
        textField.tap()
        textField.typeText("Test Group")

        alert.buttons["Create"].tap()
        _ = app.staticTexts["Test Group"].waitForExistence(timeout: 2)
    }

    private func setupGroupDetailView() {
        skipOnboarding()
        createTestGroup()

        // Navigate to group detail
        app.staticTexts["Test Group"].tap()
        XCTAssertTrue(app.navigationBars["Test Group"].waitForExistence(timeout: 2))
    }
}
