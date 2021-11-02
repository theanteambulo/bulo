//
//  Project-CoreDataExtensions.swift
//  Bulo
//
//  Created by Jake King on 15/10/2021.
//

import Foundation
import SwiftUI

extension Project {
    /// The potential colors a project could be.
    static let colors = [
        "Pink",
        "Purple",
        "Red",
        "Orange",
        "Gold",
        "Green",
        "Teal",
        "Light Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]

    /// The unwrapped title of a project.
    var projectTitle: String {
        title ?? NSLocalizedString("New Project",
                                   comment: "Create a new project")
    }

    /// The unwrapped description of a project.
    var projectDetail: String {
        detail ?? ""
    }

    /// The unwrapped color of a project.
    var projectColor: String {
        color ?? "Light Blue"
    }

    // The unwrapped items a project is parent to of.
    var projectItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    /// The default sorting algorithm for project items.
    ///
    /// By default the project items are stored with incomplete items ahead of complete items, then sorted
    /// by their relative priorities, and finally by their creation date.
    var projectItemsDefaultSorted: [Item] {
        projectItems.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }

            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }

            return first.itemCreationDate <= second.itemCreationDate
        }
    }

    /// A LocalizedStringKey to create a "more human" accessibility label for VoiceOver to read.
    var label: LocalizedStringKey {
        // swiftlint:disable:next line_length
        LocalizedStringKey("\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete")
    }

    /// The completion amount of a given project, calculated based on the number of items in that project
    /// that have been marked as completed so far.
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else { return 0 }

        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }

    /// Creates an example project to make previewing easier.
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project."
        project.closed = true
        project.creationDate = Date()
        return project
    }

    /// Sorts project items using a specified sorting method.
    /// - Parameter sortOrder: The sorting method to be used to sort items.
    /// - Returns: An array of items sorted according to the specified sorting method.
    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .title:
            return projectItems.sorted(by: \Item.itemTitle)
        case .creationDate:
            return projectItems.sorted(by: \Item.itemCreationDate)
        case .optimized:
            return projectItemsDefaultSorted
        }
    }
}
