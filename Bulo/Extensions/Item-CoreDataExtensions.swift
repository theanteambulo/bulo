//
//  Item-CoreDataExtensions.swift
//  Bulo
//
//  Created by Jake King on 15/10/2021.
//

import Foundation

extension Item {
    /// An enum containing cases for possible sorting methods for project items.
    enum SortOrder {
        case optimized, title, creationDate
    }

    /// The unwrapped title of an item.
    var itemTitle: String {
        title ?? NSLocalizedString("New Item", comment: "Create a new item")
    }

    /// The unwrapped description of an item.
    var itemDetail: String {
        detail ?? ""
    }

    /// The unwrapped creation date of an item.
    var itemCreationDate: Date {
        creationDate ?? Date()
    }

    /// Creates an example item to make previewing easier.
    static var example: Item {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example item"
        item.priority = 3
        item.creationDate = Date()
        return item
    }
}
