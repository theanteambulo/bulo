//
//  AppDelegate.swift
//  Bulo
//
//  Created by Jake King on 17/12/2021.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    /// Retrieves the configuration data for UIKit to use when creating a new scene.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - connectingSceneSession: The session object associated with the scene.
    ///   - options: System specific objects for configuring the scene.
    /// - Returns: The configuration object containing the information needed to create the scene.
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default",
                                                      sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}
