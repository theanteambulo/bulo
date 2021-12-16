//
//  ProductView.swift
//  Bulo
//
//  Created by Jake King on 16/12/2021.
//

import StoreKit
import SwiftUI

struct ProductView: View {
    @EnvironmentObject var unlockManager: UnlockManager
    let product: SKProduct

    var localizedPrice: Text {
        Text("\(product.localizedPrice)")
    }

    var getUnlimitedProjectsTerms: Text {
        Text(.getUnlimitedProjectsTerms) + localizedPrice
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(.getUnlimitedProjectsTitle)
                    .font(.headline)
                    .padding(.top, 10)

                getUnlimitedProjectsTerms

                Text(.restoreUnlimitedProjects)

                Button(Strings.buyButton.localized, action: unlock)
                    .buttonStyle(PurchaseButton())

                Button(Strings.restoreButton.localized, action: unlockManager.restore)
                    .buttonStyle(PurchaseButton())
            }
        }
    }

    func unlock() {
        unlockManager.buyProduct(product: product)
    }
}
