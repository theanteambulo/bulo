//
//  BuloTests.swift
//  BuloTests
//
//  Created by Jake King on 04/11/2021.
//

import CoreData
import XCTest
@testable import Bulo

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
