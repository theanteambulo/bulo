//
//  ProjectsView.swift
//  Bulo
//
//  Created by Jake King on 14/10/2021.
//

import SwiftUI

struct ProjectsView: View {
    @StateObject var viewModel: ViewModel
    /// Boolean to indicate whether the ActionSheet for sorting project items should be displayed.
    @State private var showingSortOrderActionSheet = false
    /// Tag value for the Open Projects tab.
    static let openTag: String? = "Open"
    /// Tag value for the Closed Projects tab.
    static let closedTag: String? = "Closed"

    init(dataController: DataController,
         showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController,
                                  showClosedProjects: showClosedProjects)

        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// A view containing a list of the user's projects where each project has a sublist displaying its
    /// associated items.
    ///
    /// The "Add Projects" button is only displayed on the Open Projects tab, where it makes logical sense.
    var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project,
                                    item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: project)
                    }

                    if viewModel.showClosedProjects == false {
                        Button {
                            withAnimation {
                                viewModel.addItem(to: project)
                            }
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
            if viewModel.showClosedProjects == false {
                // In iOS 14.3 VoiceOver has a glitch that reads the label "Add Project"
                // as "Add", no matter what accessibility label we give this button when
                // using a label. As a result, when VoiceOver is running we use a text
                // view for the button instead, forcing a correct reading without losing
                // the original layout.                
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
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
                if viewModel.projects.count == 0 {
                    Text(.noProjectsPlaceholder)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    projectsList
                }
            }
            .navigationTitle(viewModel.showClosedProjects
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
                                .default(Text(.sortOrderOptimised)) { viewModel.sortOrder = .optimized },
                                .default(Text(.sortOrderDateCreated)) { viewModel.sortOrder = .creationDate},
                                .default(Text(.sortOrderAlphabetical)) { viewModel.sortOrder = .title},
                                .cancel()
                            ]
                )
            }

            DefaultDetailView()
        }
        .sheet(isPresented: $viewModel.showingUnlockView) {
            UnlockView()
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(dataController: DataController.preview,
                     showClosedProjects: false)
    }
}
