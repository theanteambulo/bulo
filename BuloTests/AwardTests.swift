//
//  AwardTests.swift
//  BuloTests
//
//  Created by Jake King on 04/11/2021.
//

import CoreData
import XCTest
@testable import Bulo

class AwardTests: BaseTestCase {
    /// All possible awards a user could earn.
    let awards = Award.allAwards

    /// Verifies that each award's ID matches its name.
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id,
                           award.name,
                           "Award ID should always match its name")
        }
    }

    /// Verifies that new users have not earned any awards.
    func testNoAwards() throws {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award),
                           "New users should have no earned awards")
        }
    }

    /// Verifies when the user has added a certain number of items they have earned the correct number of awards.
    func testAddingItems() throws {
        let values = [
            1,
            10,
            20,
            50,
            100,
            250,
            500,
            1000
        ]

        for (count, value) in values.enumerated() {
            var items = [Item]()

            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                items.append(item)
            }

            let matches = awards.filter { award in
                award.criterion == "items" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count,
                           count + 1,
                           "Adding \(value) items should unlock \(count + 1) awards")

            for item in items {
                dataController.delete(item)
            }
        }
    }

    /// Verifies when the user has completed a certain number of items they have earned the correct number of awards.
    func testCompletingItems() throws {
        let values = [
            1,
            10,
            20,
            50,
            100,
            250,
            500,
            1000
        ]

        for (count, value) in values.enumerated() {
            var items = [Item]()

            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
                items.append(item)
            }

            let matches = awards.filter { award in
                award.criterion == "complete" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count,
                           count + 1,
                           "Completing \(value) items should unlock \(count + 1) awards")

            for item in items {
                dataController.delete(item)
            }
        }
    }
}
