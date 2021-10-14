//
//  DataController.swift
//  Bulo
//
//  Created by Jake King on 13/10/2021.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
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
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url =  URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func createSampleData() throws {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(i)"
            project.creationDate = Date()
            project.detail = "Detail for project \(i)"
            project.closed = Bool.random()
            project.items = []
            
            for j in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(j)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.priority = Int16.random(in: 1...3)
                item.project = project
            }
        }
        
        try viewContext.save()
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequestItems: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequestItems = NSBatchDeleteRequest(fetchRequest: fetchRequestItems)
        _ = try? container.viewContext.execute(batchDeleteRequestItems)
        
        let fetchRequestProjects: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequestProjects = NSBatchDeleteRequest(fetchRequest: fetchRequestProjects)
        _ = try? container.viewContext.execute(batchDeleteRequestProjects)
    }
}
