//
//  ExtensionTests.swift
//  BuloTests
//
//  Created by Jake King on 08/11/2021.
//

import SwiftUI
import XCTest
@testable import Bulo

class ExtensionTests: XCTestCase {
    /// Verifies extension on Sequence to handle sorting of values using a key path works as expected.
    func testSequenceKeyPathSortingSelf() {
        // Given
        let items = [1, 2, 5, 4, 3]

        // When
        let sortedItems = items.sorted(by: \.self)

        // Then
        XCTAssertEqual(sortedItems,
                       [1, 2, 3, 4, 5],
                       "The sorted numbers must be ascending.")
    }

    /// Verifies extension on Sequence to handle sorting of values using a custom comparator function
    /// and a key path works as expected.
    func testSequenceKeyPathSortingCustom() {
        // Given
        struct Example: Equatable {
            let value: String
        }

        let exampleJake = Example(value: "Jake")
        let exampleCal = Example(value: "Cal")
        let exampleDan = Example(value: "Dan")
        let exampleTom = Example(value: "Tom")
        let array = [exampleCal, exampleDan, exampleTom, exampleJake]

        // When
        let sortedItems = array.sorted(by: \.value) {
            $0 > $1
        }

        // Then
        XCTAssertEqual(sortedItems,
                       [exampleTom, exampleJake, exampleDan, exampleCal],
                       "Reverse sorting should yield Tom, Jake, Dan, Cal")
    }

    /// Verifies the extension on Bundle that locates, loads and decodes JSON data works as expected for a specific
    /// data type.
    func testBundleDecodingAwards() {
        // Given
        let awards = Bundle.main.decode([Award].self,
                                        from: "Awards.json")

        // Then
        XCTAssertFalse(awards.isEmpty,
                       "Awards.json should decode to a non-empty array.")
    }

    /// Verifies the extension on Bundle that locates, loads and decodes JSON data works as expected for the simplest
    /// kind of JSON - a single value.
    func testDecodingString() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)

        // When
        let data = bundle.decode(String.self, from: "DecodableString.json")

        // Then
        XCTAssertEqual(data,
                       "This is my first app and these are the first tests I'm writing.",
                       "The decoded string must match the content of DecodableString.json.")
    }

    /// Verifies the extension on Bundle that locates, loads and decodes JSON data works as expected for dictionaries
    /// of data.
    func testDecodingDictionary() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)

        // When
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")

        // Then
        XCTAssertEqual(data.count,
                       3,
                       "There should be three items decoded from DecodableDictionary.json.")

        XCTAssertEqual(data["One"],
                       1,
                       "The dictionary should contain Int to String mappings.")
    }

    /// Verifies the extension on Binding that modifies Binding instances to call a method when changed works as
    /// expected.
    func testBindingOnChangeCallsFunction() {
        // Given
        var onChangeFunctionRun = false
        var storedValue = ""

        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        let bindingToChange = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let changedBinding = bindingToChange.onChange(exampleFunctionToCall)

        // When
        changedBinding.wrappedValue = "Test string"

        // Then
        XCTAssertTrue(onChangeFunctionRun,
                      "The onChange() function was not run.")
    }
}
