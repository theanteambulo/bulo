//
//  ContentView.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import SwiftUI

struct ContentView: View {
    // Note SceneStorage is a better choice than AppStorage here because
    // SceneStorage attaches values to individual instances of the application,
    // avoiding behaviour on iPad where running two instances of the application
    // in split-screen mode results in both instances remaining in synchronous
    // states, like with AppStorage. SceneStorage also has the advantage that
    // it doesn't use UserDefaults, so it won't clash with other values.
    /// The tab that is currently selected by the user.
    @SceneStorage("selectedView") var selectedView: String?
    /// The currently active DataController.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text(.homeTab)
                }

            ProjectsView(dataController: dataController,
                         showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text(.openTab)
                }

            ProjectsView(dataController: dataController,
                         showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text(.closedTab)
                }

            AwardsView()
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text(.awardsTab)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext,
                          dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
