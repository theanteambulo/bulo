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
                            Label("Add Item", systemImage: "plus")
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
                    .font(.title2)
            }
        }
    }

    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if showClosedProjects == false {
                Button(action: addProject) {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                            .font(.title2)
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text("Nothing to see here...")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    projectsList
                }
            }
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                sortOrderToolbarItem
                addProjectToolbarItem
            }
            .actionSheet(isPresented: $showingSortOrderActionSheet) {
                ActionSheet(title: Text("Sort Items"),
                            message: Text("How would you like to sort project items?"),
                            buttons: [
                                .default(Text("Optimised")) { sortOrder = .optimized },
                                .default(Text("Date Created")) { sortOrder = .creationDate},
                                .default(Text("Alphabetically")) { sortOrder = .title},
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
