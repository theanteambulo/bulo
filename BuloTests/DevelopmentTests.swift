//
//  DevelopmentTests.swift
//  BuloTests
//
//  Created by Jake King on 05/11/2021.
//

import CoreData
import XCTest
@testable import Bulo

class DevelopmentTests: BaseTestCase {

    /// Verifies that creating sample data results in having 5 projects and 50 items.
    func testSampleDataCreationWorks() throws {
        // Given
        try dataController.createSampleData()

        // Then
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()),
                       5,
                       "There should be 5 sample projects.")

        XCTAssertEqual(dataController.count(for: Item.fetchRequest()),
                       50,
                       "There should be 50 sample items.")
    }

    /// Verifies that the deleteAll() method removes all data from the Core Data context.
    func testDeleteAllClearsEverything() throws {
        // Given
        try dataController.createSampleData()

        // When
        dataController.deleteAll()

        // Then
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()),
                       0,
                       "deleteAll() should leave 0 projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()),
                       0,
                       "deleteAll() should leave 0 items.")
    }

    /// Verifies that when a new test project is created it is set to be closed by default.
    func testExampleProjectIsClosed() {
        // Given
        let project = Project.example

        // Then
        XCTAssertTrue(project.closed,
                      "The example project should be closed by default.")
    }

    /// Verifies that when a new test item is created it is set to be high priority by default.
    func testExampleItemHighPriority() {
        // Given
        let item = Item.example

        // Then
        XCTAssertEqual(item.priority,
                      3,
                      "The example item should have high priority by default.")
    }
}
