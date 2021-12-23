//
//  SignInView.swift
//  Bulo
//
//  Created by Jake King on 23/12/2021.
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    // The potential authentication statuses of a user.
    enum SignInStatus {
        case unknown
        case authorized
        case failure(Error?)
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    // Tracks the user's authentication status.
    @State private var status = SignInStatus.unknown

    var body: some View {
        NavigationView {
            Group {
                switch status {
                case .unknown:
                    VStack(alignment: .leading) {
                        ScrollView {
                            Text("""
                                 To keep our community safe, we ask that you sign in before commenting on a project.

                                 We don't track your personal information; your name is only used for display purposes.

                                 Note: we reserve the right to remove messages which are inappropriate or offensive.
                                 """)
                        }

                        Spacer()

                        SignInWithAppleButton(onRequest: configureSignIn,
                                              onCompletion: completeSignIn)
                            .frame(height: 44)
                            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)

                        Button("Cancel", action: close)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                case .authorized:
                    Text("You're all set!")
                case .failure(let error):
                    if let error = error {
                        Text("Sorry, there was an error: \(error.localizedDescription)")
                    } else {
                        Text("Sorry, there was an error.")
                    }
                }
            }
            .padding()
            .navigationTitle("Please sign in")
        }
    }

    /// Handles configuration of a Sign in with Apple request.
    /// - Parameter request: The Sign in with Apple request to configure.
    func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
    }

    /// Handles completion of the request, successful or otherwise.
    /// - Parameter result: The result of the request completing.
    func completeSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        // We're given an instance of ASAuthorization which may contain login credentials.
        case .success(let auth):
            // If they're there, fetch the login credentials.
            if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
                // Check fullName is contained in the login credentials.
                if let fullName = appleID.fullName {
                    // Convert the fullName PersonNameComponents object into a String.
                    let formatter = PersonNameComponentsFormatter()
                    var username = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)

                    // Do not allow empty usernames and instead generate a random user ID.
                    if username.isEmpty {
                        username = "User-\(Int.random(in: 10001...99999))"
                    }

                    // Stash the user data somewhere safe - Apple sends us the user details exactly once ever.
                    UserDefaults.standard.set(username, forKey: "username")
                    NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
                    status = .authorized
                    close()
                    return
                }
            }

            status = .failure(nil)
        case .failure(let error):
            // Check the underlying problem.
            if let error = error as? ASAuthorizationError {
                // User cancelled - a soft failure.
                if error.errorCode == ASAuthorizationError.canceled.rawValue {
                    status = .unknown
                    return
                }
            }

            // Apple refused to authenticate the user - a hard failure.
            status = .failure(error)
        }
    }

    /// Dismisses the current view.
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
