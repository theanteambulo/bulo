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
        try dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()),
                       5,
                       "There should be 5 sample projects.")

        XCTAssertEqual(dataController.count(for: Item.fetchRequest()),
                       50,
                       "There should be 50 sample items.")
    }

    /// Verifies that the deleteAll() method removes all data from the Core Data context.
    func testDeleteAllClearsEverything() throws {
        try dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()),
                       0,
                       "deleteAll() should leave 0 projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()),
                       0,
                       "deleteAll() should leave 0 items.")
    }
}
