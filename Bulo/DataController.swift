//
//  DataController.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import CoreData
import CoreSpotlight
import StoreKit
import SwiftUI
import UserNotifications

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
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

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

    func appLaunched() {
        // Check the user has at least 5 projects.
        guard count(for: Project.fetchRequest()) >= 5 else {
            return
        }

        // Find all scenes.
        let allScenes = UIApplication.shared.connectedScenes

        // Get the one that's currently receiving user input.
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        // Request for a review prompt to appear there.
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
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

    /// Batch deletes all projects and items from the Core Data context.
    func deleteAll() {
        let fetchRequestItems: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequestItems = NSBatchDeleteRequest(fetchRequest: fetchRequestItems)
        _ = try? container.viewContext.execute(batchDeleteRequestItems)

        let fetchRequestProjects: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequestProjects = NSBatchDeleteRequest(fetchRequest: fetchRequestProjects)
        _ = try? container.viewContext.execute(batchDeleteRequestProjects)
    }

    /// Counts the number of objects in the Core Data context for a given FetchRequest, without actually having to
    /// execute that FetchRequest to get the count.
    /// - Returns: A count of the objects in the Core Data context for a given FetchRequest.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Determines whether the user has earned a given award.
    /// - Parameter award: The award to test whether the user has earned or not.
    /// - Returns: Boolean indicating whether the user has earned the award or not.
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            // returns true if the user added a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "complete":
            // returns true if the user completed a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            // an unknown criterion; this should never be allowed
            // fatalError("Unknown award criterion \(award.criterion)")
            return false
        }
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

    /// Add a reminder to a given project.
    /// - Parameters:
    ///   - project: The project to add a reminder to.
    ///   - completion: Handler function to send back any errors that arise during notification work.
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // The hub of UserNotifications framework responsible for reading and writing notifications.
        let center = UNUserNotificationCenter.current()

        // Determine the user's notification settings.
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            // If not already determined, determine the user's settings.
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        // Permission granted, place reminders.
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        // Permission denied, failure.
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            // If already authorised, place reminders by passing in completion closure.
            case .authorized:
                self.placeReminders(for: project,
                                    completion: completion)
            // Failure - call completion handler directly.
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Removes a reminder from a given project.
    /// - Parameter project: The project to remove the reminder from.
    func removeReminders(for project: Project) {
        // Get the project ID.
        let projectID = project.objectID.uriRepresentation().absoluteString

        // The hub of UserNotifications framework responsible for reading and writing notifications.
        let center = UNUserNotificationCenter.current()

        // Remove pending notification requests for the project from the notification center.
        center.removePendingNotificationRequests(withIdentifiers: [projectID])
    }

    /// Requests notification privileges from the user.
    /// - Parameter completion: Handler function to send back any errors that arise during notification work.
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        // The hub of UserNotifications framework responsible for reading and writing notifications.
        let center = UNUserNotificationCenter.current()

        // Request permission to display alert and play a sound, then call completion handler.
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }

    /// Places a single notification for a given project.
    /// - Parameters:
    ///   - project: The project to place a notification for.
    ///   - completion: Handler function to send back any errors that arise during notification work.
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // Dictate the content of the notification.
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle

        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }

        // Define the calendar trigger of the notification - the circumstance under which it is shown.
        let components = Calendar.current.dateComponents([.hour, .minute],
                                                         from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Wrap the content and trigger up in a single notification with a unique ID.
        let projectID = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(
            identifier: projectID,
            content: content,
            trigger: trigger
        )

        // Send notification request to iOS.
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    // Notification successfully scheduled.
                    completion(true)
                } else {
                    // Notification not scheduled.
                    completion(false)
                }
            }
        }
    }
}
