//
//  UnlockView.swift
//  Bulo
//
//  Created by Jake King on 16/12/2021.
//

import StoreKit
import SwiftUI

struct UnlockView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager

    var body: some View {
        VStack {
            switch unlockManager.requestState {
            case .loaded(let product):
                ProductView(product: product)
            case .failed:
                Text(.storeLoadingError)
            case .loading:
                ProgressView(Strings.storeLoading.localized)
            case .purchased:
                Text(.purchaseThankYouMessage)
            case .deferred:
                Text(.deferredPurchaseThankYouMessage)
            }

            Button("Dismiss", action: dismiss)
        }
        .padding()
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView()
    }
}
