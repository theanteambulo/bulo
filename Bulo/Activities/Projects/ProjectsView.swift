//
//  ProjectsView.swift
//  Bulo
//
//  Created by Jake King on 14/10/2021.
//

import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    /// Boolean to indicate whether the ActionSheet for sorting project items should be displayed.
    @State private var showingSortOrderActionSheet = false
    /// The currently selected sorting method.
    @State private var sortOrder = Item.SortOrder.optimized

    /// Boolean to indicate whether open or closed projects are being shown
    let showClosedProjects: Bool
    /// The user's projects.
    let projects: FetchRequest<Project>

    /// Tag value for the Open Projects tab.
    static let openTag: String? = "Open"
    /// Tag value for the Closed Projects tab.
    static let closedTag: String? = "Closed"

    // Construct a fetch request to show the user's projects, depending on whether we are in the Open or
    // Closed Projects tab.
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects

        projects = FetchRequest<Project>(entity: Project.entity(),
                                         sortDescriptors: [
                                            NSSortDescriptor(keyPath: \Project.creationDate,
                                                             ascending: false)
                                         ],
                                         predicate: NSPredicate(format: "closed = %d",
                                                                showClosedProjects)
        )
    }

    /// A view containing a list of the user's projects where each project has a sublist displaying its
    /// associated items.
    ///
    /// The "Add Projects" button is only displayed on the Open Projects tab, where it makes logical sense.
    var projectsList: some View {
        List {
            ForEach(projects.wrappedValue) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: sortOrder)) { item in
                        ItemRowView(project: project,
                                    item: item)
                    }
                    .onDelete { offsets in
                        delete(offsets, from: project)
                    }

                    if showClosedProjects == false {
                        Button {
                            addItem(to: project)
                        } label: {
                            Label(Strings.addItem.localized, systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    /// A toolbar item containing a button for choosing a project item sorting method.
    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrderActionSheet.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    /// A toolbar item containing a button for adding a new project.
    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if showClosedProjects == false {
                // In iOS 14.3 VoiceOver has a glitch that reads the label "Add Project"
                // as "Add", no matter what accessibility label we give this button when
                // using a label. As a result, when VoiceOver is running we use a text
                // view for the button instead, forcing a correct reading without losing
                // the original layout.                
                Button(action: addProject) {
                    if UIAccessibility.isVoiceOverRunning {
                        Text(.addProject)
                    } else {
                        Label(Strings.addProject.localized, systemImage: "plus")
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text(.noProjectsPlaceholder)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    projectsList
                }
            }
            .navigationTitle(showClosedProjects
                             ? Text(.closedProjects)
                             : Text(.openProjects))
            .toolbar {
                sortOrderToolbarItem
                addProjectToolbarItem
            }
            .actionSheet(isPresented: $showingSortOrderActionSheet) {
                ActionSheet(title: Text(.sortItemsTitle),
                            message: Text(.sortItemsMessage),
                            buttons: [
                                .default(Text(.sortOrderOptimised)) { sortOrder = .optimized },
                                .default(Text(.sortOrderDateCreated)) { sortOrder = .creationDate},
                                .default(Text(.sortOrderAlphabetical)) { sortOrder = .title},
                                .cancel()
                            ]
                )
            }

            DefaultDetailView()
        }
    }

    /// Saves a new project to the Core Data context.
    func addProject() {
        withAnimation {
            let project = Project(context: managedObjectContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }
    }

    /// Saves a new item associated with a given parent project to the Core Data context.
    /// - Parameter project: The parent project for the newly added item.
    func addItem(to project: Project) {
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
    }

    /// Deletes an item from a given parent project from the Core Data context.
    /// - Parameters:
    ///   - offsets: A set of indices relative to the list of items.
    ///   - project: The parent project of the item to be deleted.
    func delete(_ offsets: IndexSet,
                from project: Project) {
        let allItems = project.projectItems(using: sortOrder)

        for offset in offsets {
            let item = allItems[offset]
            dataController.delete(item)
        }

        dataController.save()
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext,
                          dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
