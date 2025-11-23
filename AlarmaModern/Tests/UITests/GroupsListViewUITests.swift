//
//  GroupsListViewUITests.swift
//  AlarmaModernUITests
//
//  UI tests for GroupsListView
//

import XCTest

@MainActor
final class GroupsListViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testGroupsListInitialState() throws {
        // Skip onboarding for tests
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.exists {
            getStartedButton.tap()
        }

        let enableNotificationsButton = app.buttons["Enable Notifications"]
        if enableNotificationsButton.exists {
            let notNowButton = app.buttons["Not Now"]
            notNowButton.tap()
        }

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Alarms"].exists)

        // Verify toolbar buttons exist
        XCTAssertTrue(app.buttons["Edit"].exists)
        XCTAssertTrue(app.buttons["Add Group"].exists)
    }

    func testCreateGroup() throws {
        skipOnboarding()

        // Tap add button
        app.buttons["Add Group"].tap()

        // Wait for alert
        let alert = app.alerts["New Alarm Group"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Enter group name
        let textField = alert.textFields["Group Name"]
        textField.tap()
        textField.typeText("Morning Routine")

        // Tap create
        alert.buttons["Create"].tap()

        // Verify group appears in list
        XCTAssertTrue(app.staticTexts["Morning Routine"].waitForExistence(timeout: 2))
    }

    func testDeleteGroup() throws {
        skipOnboarding()
        createTestGroup(named: "To Delete")

        // Enter edit mode
        app.buttons["Edit"].tap()

        // Find and delete the group
        let groupCell = app.cells.containing(.staticText, identifier: "To Delete").firstMatch
        XCTAssertTrue(groupCell.exists)

        let deleteButton = groupCell.buttons.matching(identifier: "Delete").firstMatch
        deleteButton.tap()

        // Confirm deletion
        if app.buttons["Delete"].exists {
            app.buttons["Delete"].tap()
        }

        // Exit edit mode
        app.buttons["Done"].tap()

        // Verify group is deleted
        XCTAssertFalse(app.staticTexts["To Delete"].exists)
    }

    func testNavigateToGroupDetail() throws {
        skipOnboarding()
        createTestGroup(named: "Work Alarms")

        // Tap on the group
        app.staticTexts["Work Alarms"].tap()

        // Verify detail view is shown
        XCTAssertTrue(app.navigationBars["Work Alarms"].waitForExistence(timeout: 2))
    }

    func testToggleGroupEnabled() throws {
        skipOnboarding()
        createTestGroup(named: "Test Group")

        // Find the toggle switch for the group
        let groupCell = app.cells.containing(.staticText, identifier: "Test Group").firstMatch
        let toggle = groupCell.switches.firstMatch

        XCTAssertTrue(toggle.exists)

        // Get initial state
        let initialState = toggle.value as? String == "1"

        // Toggle
        toggle.tap()

        // Verify state changed
        let newState = toggle.value as? String == "1"
        XCTAssertNotEqual(initialState, newState)
    }

    func testEmptyStateMessage() throws {
        skipOnboarding()

        // If there are groups, delete them first
        if !app.staticTexts["No Alarm Groups"].exists {
            deleteAllGroups()
        }

        // Verify empty state
        XCTAssertTrue(app.staticTexts["No Alarm Groups"].exists)
        XCTAssertTrue(app.staticTexts["Create your first alarm group to get started"].exists)
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

        // Wait for main view to appear
        _ = app.navigationBars["Alarms"].waitForExistence(timeout: 2)
    }

    private func createTestGroup(named name: String) {
        app.buttons["Add Group"].tap()

        let alert = app.alerts["New Alarm Group"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        let textField = alert.textFields["Group Name"]
        textField.tap()
        textField.typeText(name)

        alert.buttons["Create"].tap()

        // Wait for group to appear
        _ = app.staticTexts[name].waitForExistence(timeout: 2)
    }

    private func deleteAllGroups() {
        app.buttons["Edit"].tap()

        while app.cells.count > 0 {
            let firstCell = app.cells.firstMatch
            if firstCell.exists {
                let deleteButton = firstCell.buttons.matching(identifier: "Delete").firstMatch
                if deleteButton.exists {
                    deleteButton.tap()
                    if app.buttons["Delete"].exists {
                        app.buttons["Delete"].tap()
                    }
                }
            } else {
                break
            }
        }

        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        }
    }
}
