//
//  Sequence-Extensions.swift
//  Bulo
//
//  Created by Jake King on 19/10/2021.
//

import Foundation

extension Sequence {
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
}
