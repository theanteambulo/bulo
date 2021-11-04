//
//  ProjectTests.swift
//  BuloTests
//
//  Created by Jake King on 04/11/2021.
//

import CoreData
import XCTest
@testable import Bulo

class ProjectTests: BaseTestCase {

    /// Verify that Core Data creates projects and items in storage as expected.
    func testCreatingProjectsAndItems() {
        let targetCount = 10

        for _ in 0..<targetCount {
            let project = Project(context: managedObjectContext)

            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()),
                       targetCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()),
                       targetCount * targetCount)
    }

    /// Verifies that the Core Data cascade delete system is working.
    func testDeletingProjectCascadeDeletesItems() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)

        dataController.delete(projects[0])

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()),
                       4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()),
                       40)
    }
}
