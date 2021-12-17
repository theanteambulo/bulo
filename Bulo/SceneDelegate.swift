//
//  SceneDelegate.swift
//  Bulo
//
//  Created by Jake King on 17/12/2021.
//

import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @Environment(\.openURL) var openURL

    /// Tells the delegate about the addition of a scene to the app.
    /// - Parameters:
    ///   - scene: The scene object being connected to the app.
    ///   - session: The session object containing details about the scene's configuration.
    ///   - connectionOptions: Additional options for configuring the scene.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // If there was a shortcut item that triggered the scene connection...
        if let shortcutItem = connectionOptions.shortcutItem {
            // Attempt to convert that to a URL.
            guard let url = URL(string: shortcutItem.type) else {
                return
            }

            // Open the URL.
            openURL(url)
        }
    }

    /// Asks the delegate to perform the user-selected action.
    /// - Parameters:
    ///   - windowScene: The window scene object receiving the shortcut item.
    ///   - shortcutItem: The action selected by the user.
    ///   - completionHandler: A handler block to call after the specified action is completed.
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            // We were unable to handle the URL.
            completionHandler(false)
            return
        }

        // We were able to handle the URL.
        openURL(url, completion: completionHandler)
    }
}
