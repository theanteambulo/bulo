//
//  DataController-StoreKit.swift
//  Bulo
//
//  Created by Jake King on 18/12/2021.
//

import StoreKit

extension DataController {
    func appLaunched() {
        // Check the user has at least 5 projects.
        guard count(for: Project.fetchRequest()) >= 5 else {
            return
        }

            // Find all scenes.
            let allScenes = UIApplication.shared.connectedScenes

            // Get the one that's currently receiving user input.
            let scene = allScenes.first { $0.activationState == .foregroundActive }

            // Request for a review prompt to appear there.
            if let windowScene = scene as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
    }
}
