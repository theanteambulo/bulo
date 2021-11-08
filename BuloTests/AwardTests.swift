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
        // Given
        for award in awards {
            // Then
            XCTAssertEqual(award.id,
                           award.name,
                           "Award ID should always match its name")
        }
    }

    /// Verifies that new users have not earned any awards.
    func testNoAwards() throws {
        // Given
        for award in awards {
            // Then
            XCTAssertFalse(dataController.hasEarned(award: award),
                           "New users should have no earned awards")
        }
    }

    /// Verifies the number of awards for the user to earn with each criterion is correct in the Awards.json file.
    func testAwardsToEarn() throws {
        // Given
        let itemsAddedAwards = awards.filter { award in
            award.criterion == "items"
        }

        let itemsCompletedAwards = awards.filter { award in
            award.criterion == "complete"
        }

        let chatAwards = awards.filter { award in
            award.criterion == "chat"
        }

        let premiumUnlockAwards = awards.filter { award in
            award.criterion == "unlock"
        }

        // When
        XCTAssertEqual(itemsAddedAwards.count,
                       8,
                       "There should be 8 awards to earn.")

        XCTAssertEqual(itemsCompletedAwards.count,
                       8,
                       "There should be 8 awards to earn.")

        XCTAssertEqual(chatAwards.count,
                       3,
                       "There should be 8 awards to earn.")

        XCTAssertEqual(premiumUnlockAwards.count,
                       1,
                       "There should be 8 awards to earn.")
    }

    /// Verifies when the user has added a certain number of items they have earned the correct number of awards.
    func testAddingItems() throws {
        // Given
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
            for _ in 0..<value {
                _ = Item(context: managedObjectContext)
            }

            // When
            let matches = awards.filter { award in
                award.criterion == "items" && dataController.hasEarned(award: award)
            }

            // Then
            XCTAssertEqual(matches.count,
                           count + 1,
                           "Adding \(value) items should unlock \(count + 1) awards")

                dataController.deleteAll()
        }
    }

    /// Verifies when the user has completed a certain number of items they have earned the correct number of awards.
    func testCompletingItems() throws {
        // Given
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
            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
            }

            // When
            let matches = awards.filter { award in
                award.criterion == "complete" && dataController.hasEarned(award: award)
            }

            // Then
            XCTAssertEqual(matches.count,
                           count + 1,
                           "Completing \(value) items should unlock \(count + 1) awards")

                dataController.deleteAll()
        }
    }
}
