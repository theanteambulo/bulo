//
//  UnlockManager.swift
//  Bulo
//
//  Created by Jake King on 15/12/2021.
//

// Combine allows us to use the ObservableObject protocol.
import Combine
// StoreKit enables us to work with Apple's in-app purchases API.
import StoreKit

// UnlockManager conforms to several protocols.
// NSObject: enables the class to act as a StoreKit delegate.
// ObservableObject: ensures views are updated when the purchasing state changes.
// SKPaymentTransactionObserver: ensures any purchases happening are being watched.
// SKProductsRequestDelegate: enables the class to request products from Apple.
/// Handles all work associated with in-app purchases.
class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    /// Each possible state of a purchase request.
    enum RequestState {
        case loading // Started request, no response yet.
        case loaded(SKProduct) // Successful response from Apple describing product(s) available for purchase.
        case failed(Error?) // Something went wrong with i) request for products, or ii) a purchase attempt.
        case purchased // Successful purchase of IAP or restoration of a previous purchase.
        case deferred // User can't make purchase and needs external action, e.g. a child needs parent permission.
    }

    /// Custom errors to describe scenarios which should never arise.
    ///
    /// invalidIdentifiers: a non-existent product has been requested.
    /// missingProduct: the request completes but doesn't find the unlock for the app.
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    /// Stores current state of purchase request.
    ///
    /// Defaults to loading as it's safe when we don't know the situation.
    @Published var requestState = RequestState.loading

    /// Environment singleton responsible for managing our Core Data stack.
    ///
    /// Used to store purchase information, i.e. has the user purchased the unlock or not.
    private let dataController: DataController

    /// Responsible for fetching products from App Store Connect.
    private let request: SKProductsRequest

    /// The list of products sent back from App Store Connect.
    private var loadedProducts = [SKProduct]()

    /// Indicates whether the user is allowed to make payments.
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    init(dataController: DataController) {
        // Store the data controller sent in.
        self.dataController = dataController

        // Prepare to look for our unlock product.
        let productIDs = Set(["com.theanteambulo.Bulo.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // Required due to inheritance from NSObject.
        super.init()

        // Start watching the payment queue.
        SKPaymentQueue.default().add(self)

        // Prevent starting product request if unlock has already happened.
        guard dataController.fullVersionUnlocked == false else {
            return
        }

        // Ensure UnlockManager is notified when the request completes.
        request.delegate = self

        // Start the request.
        request.start()
    }

    deinit {
        // Stop watching the payment queue.
        SKPaymentQueue.default().remove(self)
    }

    /// Tracks the payment transaction to check whether it succeeds, fails or does something else.
    /// - Parameters:
    ///   - queue: The payments queue to track.
    ///   - transactions: The transactions to track the status of.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            // Although there's only one transaction that should be returned, by using a loop we're avoiding making
            // assumptions about the way StoreKit works and it's therefore safer.
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)

                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }

                    queue.finishTransaction(transaction)

                case .deferred:
                    self.requestState = .deferred

                default:
                    break
                }
            }
        }
    }

    /// Stores products sent back from SKProductRequest, then pulls out the first product returned.
    /// - Parameters:
    ///   - request: The products request that sends back products.
    ///   - response: The products sent back from the products request.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them.
            self.loadedProducts = response.products

            // Get the unlock product, if it exists.
            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }

            // Check to see if we got any additional invalid product identifiers.
            if response.invalidProductIdentifiers.isEmpty == false {
                print("Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            // The unlock product was the only product returned, so load it.
            self.requestState = .loaded(unlock)
        }
    }

    /// Purchases a product.
    /// - Parameter product: The product to be purchased
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// Restores the user's completed transactions.
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
