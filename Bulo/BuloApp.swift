//
//  BuloApp.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import SwiftUI

@main
struct BuloApp: App {
    // Note state object property wrapper used to ensure the data controller and unlock manager objects stay alive as
    // long as the app does.
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager

    // Tells SwiftUI to use the AppDelegate class for any UIKit functionality it can't currently handle itself.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)

        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)

        #if targetEnvironment(simulator)
        UserDefaults.standard.set("theanteambulo", forKey: "username")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                              dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
                // Automatically save when we detect that we are no longer the foreground app. Use
                // this rather than scene phase so we can port to macOS, where scene phase won't
                // detect our app losing focus.
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save)
                .onAppear(perform: dataController.appLaunched)
        }
    }

    func save(_ notification: Notification) {
        dataController.save()
    }
}
