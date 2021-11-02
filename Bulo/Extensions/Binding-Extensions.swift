//
//  Binding-Extensions.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

extension Binding {
    /// Ensures that whenever a binding's value is changed, some handler method can be called while still ensuring that reading and writing of the binding's value can continue.
    /// - Parameter handler: The method to call on change of the binding's value.
    /// - Returns: A new instance of Binding that uses the same type of data as the original binding.
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
