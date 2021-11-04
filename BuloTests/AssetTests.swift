//
//  AssetTests.swift
//  BuloTests
//
//  Created by Jake King on 04/11/2021.
//

import XCTest
@testable import Bulo

class AssetTests: XCTestCase {
    /// Verifies all the colors we expect are in our asset catalogue.
    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color),
                            "Failed to load color \(color) from asset catalogue")
        }
    }

    /// Verifies the JSON in Awards.json is valid and no changes have been made to the Awards
    /// struct such that it no longer matches the JSON.
    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false,
                      "Failed to load awards from JSON")
    }
}
