//
//  BuloPerformanceTests.swift
//  BuloPerformanceTests
//
//  Created by Jake King on 08/11/2021.
//

import CoreData
import XCTest
@testable import Bulo

class PerformanceTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
