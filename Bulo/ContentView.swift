//
//  ContentView.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import CoreSpotlight
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

    private let newProjectActivity = "com.theanteambulo.Bulo.newProject"

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

            SharedProjectsView()
                .tag(SharedProjectsView.tag)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Community")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType,
                                perform: moveToHome)
        .onContinueUserActivity(newProjectActivity,
                                perform: createProject)
        .userActivity(newProjectActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Project"
        }
        .onOpenURL(perform: openURL)
    }

    /// Adjusts the selected tab to be the Home view whenever we get a Spotlight launch.
    /// - Parameter input: Any type of NSUserActivity.
    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }

    /// Responds to URL being opened by changing the selected tab to Open Projects and creating a new project.
    /// - Parameter url: The url the app is launched from.
    func openURL(_ url: URL) {
        selectedView = ProjectsView.openTag
        dataController.addProject()
    }

    /// Responds to triggered user activity by changing the selected tab to Open Projects and creating a new project.
    /// - Parameter userActivity: The user activity triggered.
    func createProject(_ userActivity: NSUserActivity) {
        selectedView = ProjectsView.openTag
        dataController.addProject()
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
