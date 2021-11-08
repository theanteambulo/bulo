//
//  PerformanceTests.swift
//  BuloPerformanceTests
//
//  Created by Jake King on 08/11/2021.
//

import XCTest
@testable import Bulo

class PerformanceTests: PerformanceTestCase {
    /// Verifies how fast the app can calculate which awards the user has earned.
    func testAwardCalculationPerformance() throws {
        // Given
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count,
                       500,
                       "This checks the awards count is constant. Change this if wanting to add new awards.")

        // Then
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
