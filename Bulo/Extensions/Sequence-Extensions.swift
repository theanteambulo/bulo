//
//  Sequence-Extensions.swift
//  Bulo
//
//  Created by Jake King on 19/10/2021.
//

import Foundation

extension Sequence {
    /// Sorts generic objects using a specified KeyPath and sorting method.
    /// - Returns: A sorted array of elements of whichever type was specified in the KeyPath.
    func sorted<Value>(by keyPath: KeyPath<Element, Value>,
                       using areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows -> [Element] {
        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    /// Sorts comparable objects using a specified KeyPath.
    /// - Returns: A sorted array of elements of whichever type was specified in the KeyPath.
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted(by: keyPath, using: <)
    }
}
