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

    @State private var showingSortOrderActionSheet = false
    @State private var sortOrder = Item.SortOrder.optimized

    let showClosedProjects: Bool
    let projects: FetchRequest<Project>

    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"

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

    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrderActionSheet.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

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

    func addProject() {
        withAnimation {
            let project = Project(context: managedObjectContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }
    }

    func addItem(to project: Project) {
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
    }

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
