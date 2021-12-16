//
//  SKProductExtension.swift
//  Bulo
//
//  Created by Jake King on 16/12/2021.
//

import StoreKit

extension SKProduct {
    /// Shows the correct price for the product, localized to the user's preferred language.
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
