//
//  DataController-Awards.swift
//  Bulo
//
//  Created by Jake King on 18/12/2021.
//

import CoreData

extension DataController {
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
}
