//
//  ProjectsViewModel.swift
//  Bulo
//
//  Created by Jake King on 18/11/2021.
//

import CoreData
import Foundation
import SwiftUI

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// Dependency injection of the environment singleton DataController.
        let dataController: DataController
        /// Performs the initial fetch request and ensures it remains updated.
        private let projectsController: NSFetchedResultsController<Project>
        /// An array of project objects.
        @Published var projects = [Project]()
        /// The currently selected sorting method.
        var sortOrder = Item.SortOrder.optimized
        /// Boolean to indicate whether open or closed projects are being shown
        let showClosedProjects: Bool

        /// Saves a new project to the Core Data context.
        func addProject() {
            let project = Project(context: dataController.container.viewContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }

        /// Saves a new item associated with a given parent project to the Core Data context.
        /// - Parameter project: The parent project for the newly added item.
        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
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

        /// Notifies the receiver that the fetched results controller has completed processing of
        /// one or more changes due to an add, remove, move, or update.
        /// - Parameter controller: The fetched results controller that sent the message.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }

        // Construct a fetch request to show the user's projects, depending on whether we are in the Open or
        // Closed Projects tab.
        init(dataController: DataController,
             showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate,
                                                        ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d",
                                            showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil)

            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects.")
            }
        }
    }
}
