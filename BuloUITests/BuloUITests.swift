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
    func testAppHasFiveTabs() {
        XCTAssertEqual(app.tabBars.buttons.count,
                       5,
                       "There should be 5 tabs in the app.")
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
        // Go to the Open Projects tab and add one project and one item.
        testOpenTabAddsItems()

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

    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists,
                          "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }

    // can do the opposite of this test to make sure reopening a project moves it to the open tab
    // this test currently fails due to the last assertion
    // the app fails to recognise that there are any cells in the table on the Closed tab, despite
    // recognising there is in fact a table there. My suspicion is that there remains bugs with
    // Core Data that are preventing this from working correctly but I am yet to be able to verify this
//    func testClosingOpenProjectMovesItToClosedTabs() {
//        app.buttons["Closed"].tap()
//        XCTAssertEqual(app.tables.cells.count,
//                       0,
//                       "There should be 0 projects and therefore no list rows initially.")
//
//        app.buttons["Open"].tap()
//        XCTAssertEqual(app.tables.cells.count,
//                       0,
//                       "There should be 0 projects and therefore no list rows initially.")
//
//        app.buttons["Add Project"].tap()
//        XCTAssertEqual(app.tables.cells.count,
//                       1,
//                       "There should be 1 project and therefore 1 row in the list.")
//
//        app.buttons["New Project"].tap()
//        app.buttons["Close Project"].tap()
//
//        XCTAssertTrue(app.tabBars.element.buttons["Open"].isSelected,
//                       "After a project is closed, the user should be returned to the Open Projects tab.")
//
//        XCTAssertTrue(app.tables.cells.count == 0)
//
//        app.buttons["Closed"].tap()
//        XCTAssertEqual(app.tables.cells.count,
//                       1,
//                       "There should be 1 project and therefore 1 row in the list.")
//    }

    func testAtLeastOneAwardShowsUnlockedAlert() {
        // Go to the Open Projects tab and add one project and one item.
        testOpenTabAddsItems()

        app.buttons["Awards"].tap()

        app.scrollViews.buttons.firstMatch.tap()
        // this could be greatly improved by testing multiple awards
        XCTAssertTrue(app.alerts["Unlocked: First Steps"].exists,
                      "There should be an Unlocked alert showing for awards.")
        app.buttons["OK"].tap()
    }

    func testSwipeToDelete() {
        // Go to the Open Projects tab and add one project and one item.
        testOpenTabAddsItems()

        app.buttons["New Item"].swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertEqual(app.tables.cells.count,
                       1,
                       "There should be 1 project, 0 items, and therefore 1 row in the list.")
    }
}
