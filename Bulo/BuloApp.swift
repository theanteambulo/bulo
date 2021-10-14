//
//  BuloApp.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import SwiftUI

@main
struct BuloApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                              dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
