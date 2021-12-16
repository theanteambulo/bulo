//
//  PurchaseButton.swift
//  Bulo
//
//  Created by Jake King on 16/12/2021.
//

import SwiftUI

struct PurchaseButton: ButtonStyle {
    /// Creates the button style for the purchase button used in the app's store.
    /// - Parameter configuration: The button's style configuration.
    /// - Returns: A view containing the button styled exactly as outlined.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 200, minHeight: 44)
            .background(Color("Light Blue"))
            .clipShape(Capsule())
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
