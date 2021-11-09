//
//  BuloUITests.swift
//  BuloUITests
//
//  Created by Jake King on 09/11/2021.
//

import XCTest

class BuloUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    /// Verifies the app contains for tabs for the user to access.
    func testAppHasFourTabs() {
        XCTAssertEqual(app.tabBars.buttons.count,
                       4,
                       "There should be 4 tabs in the app.")
    }

    func testOpenTabAddsProjects() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       0,
                       "There should be 0 projects and therefore no list rows initially")

        for tapCount in 1...5 {
            app.buttons["Add Project"].tap()
            XCTAssertEqual(app.tables.cells.count,
                           tapCount,
                           "There should be \(tapCount) project(s) and therefore \(tapCount) row(s) in the list.")
        }
    }

    func testOpenTabAddsItems() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       0,
                       "There should be 0 projects and therefore no list rows initially")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       1,
                       "There should be 1 project and therefore 1 row in the list.")

        app.buttons["Add Item"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       2,
                       "There should be 2 items and therefore 2 rows in the list.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       0,
                       "There should be 0 projects and therefore no list rows initially.")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       1,
                       "There should be 1 project and therefore 1 row in the list.")

        app.buttons["New Project"].tap()
        app.textFields["Project name"].tap()

        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Project 2"].exists,
                      "The new project name should be visible in the list.")
    }

    func testEditingItemUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       0,
                       "There should be 0 projects and therefore no list rows initially.")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       1,
                       "There should be 1 project and therefore 1 row in the list.")

        app.buttons["Add Item"].tap()
        XCTAssertEqual(app.tables.cells.count,
                       2,
                       "There should be 1 project, 1 item and therefore 2 rows in the list.")

        app.buttons["New Item"].tap()
        app.textFields["Item name"].tap()

        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Item 2"].exists,
                      "The new item name should be visible in the list.")
    }
}
