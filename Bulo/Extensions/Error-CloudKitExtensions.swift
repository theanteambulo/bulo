//
//  Error-CloudKitExtensions.swift
//  Bulo
//
//  Created by Jake King on 24/12/2021.
//

import CloudKit
import Foundation

extension Error {
    /// Attempts to turn the Swift Error object into a String.
    /// - Returns: A String describing the error.
    func getCloudKitError() -> CloudError {
        // Convert the Swift Error object into a CKError.
        guard let error = self as? CKError else {
            // If not a CKError, return the best description of the error we can.
            return "An unknown error occurred: \(self.localizedDescription)"
        }

        // Check the code of the CKError to determine exactly what happened.
        switch error.code {
        // Fundamental logic errors exist in the code.
        case .badContainer, .badDatabase, .invalidArguments:
            return "A fatal error occurred: \(error.localizedDescription)"
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "There was a problem communicating with iCloud; please check your network connection and try again."
        case .notAuthenticated:
            return "There was a problem with your iCloud account; please check you are logged in."
        case .requestRateLimited:
            return "You've hit iCloud's rate limit; please wait and try again."
        case .quotaExceeded:
            return "You've exceeded your iCloud quota; please clear some space and try again."
        default:
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
