//
//  DataController.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import CoreData
import CoreSpotlight
import SwiftUI
import WidgetKit

/// An environment singleton responsible for managing our Core Data stack, including handling saving, counting fetch
/// requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

    /// The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults

    /// Reads and writes the full app version unlock status based on UserDefaults data.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }

    /// An instance of DataController for previewing purposes.
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()

    /// Ensures that the data model is only loaded once, ensuring only one model is loaded by the
    /// NSPersistentCloudKitContainer.
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: ".momd") else {
            fatalError("Failed to locate model file")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file")
        }

        return managedObjectModel
    }()

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing), or on
    /// permanent storage (for use in regular app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameters
    ///     - inMemory: Whether to store this data in temporary memory or not.
    ///     - defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults

        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        // For testing and previewing purposes, we create a temporary, in-memory database by writing
        // to /dev/null so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url =  URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.theanteambulo.Bulo"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            self.container.viewContext.automaticallyMergesChangesFromParent = true

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                // Note that having animations disabled can make the keyboard functionality a bit buggy
                // and means the initial key tap isn't recognised, impacting some tests.
//                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }

    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.creationDate = Date()
            project.detail = "Detail for project \(projectCounter)"
            project.closed = Bool.random()
            project.items = []

            // Each project gets 10 items.
            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.priority = Int16.random(in: 1...3)
                item.project = project
            }
        }

        try viewContext.save()
    }

    /// Saves our Core Data context iff there are changes. This silently ignores any errors caused by saving, but this
    /// should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Deletes a given object from the Core Data context.
    /// - Parameter object: The NSManagedObject to delete from the Core Data context.
    func delete(_ object: NSManagedObject) {
        // Get the object ID.
        let objectID = object.objectID.uriRepresentation().absoluteString

        // Type check.
        if object is Item {
            // If the object is an Item, delete it.
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [objectID])
        } else {
            // If the object is a Project, delete all its items.
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [objectID])
        }

        container.viewContext.delete(object)
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    /// Batch deletes all projects and items from the Core Data context.
    func deleteAll() {
        let fetchRequestItems: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequestItems)

        let fetchRequestProjects: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        delete(fetchRequestProjects)
    }

    /// Counts the number of objects in the Core Data context for a given FetchRequest, without actually having to
    /// execute that FetchRequest to get the count.
    /// - Returns: A count of the objects in the Core Data context for a given FetchRequest.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Writes the item's information to Spotlight and calls save() on the data controller to ensure Core Data is also
    /// updated.
    /// - Parameter item: The Item object to update.
    func update(_ item: Item) {
        // Create a stable unique identifier for the items being saved.
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        // Create the set of attributes to be stored in Spotlight.
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.itemTitle
        attributeSet.contentDescription = item.itemDetail

        // Wrap up identifier and attributes in a Spotlight record, passing in domain identifier.
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )

        // Send the item to Spotlight for indexing.
        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        // Ensure changed data also gets written to Core Data.
        save()
    }

    /// Converts the unique identifier of the object selected provided by Spotlight into an Item object.
    /// - Parameter uniqueIdentifier: The unique identifier of the object selected.
    /// - Returns: The Item object with the object ID matching the unique identifier passed in.
    func item(with uniqueIdentifier: String) -> Item? {
        // Convert string into a URL.
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        // Get the object ID for the URL.
        guard let objectID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        // Return the object with the matching object ID from the Core Data context.
        return try? container.viewContext.existingObject(with: objectID) as? Item
    }

    /// Saves a new project to the Core Data context if possible, otherwise toggles the showingUnlockView Boolean.
    /// - Returns: Boolean indicating whether the project was successfully added or not.
    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3

        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }

    /// Constructs a fetch request to show a specified number of the highest priority, incomplete items from open
    /// projects.
    /// - Parameter count: The fetch limit for items.
    /// - Returns: A fetch request for a given number of high priority, incomplete items from open projects.
    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let openPredicate = NSPredicate(format: "completed = false")
        let incompletePredicate = NSPredicate(format: "project.closed = false")
        itemRequest.predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [
                openPredicate,
                incompletePredicate
            ]
        )
        itemRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.priority, ascending: false)]
        itemRequest.fetchLimit = count

        return itemRequest
    }

    /// Executes a given fetch request.
    /// - Returns: The fetch request to execute.
    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
