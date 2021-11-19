//
//  ItemRowViewModel.swift
//  Bulo
//
//  Created by Jake King on 19/11/2021.
//

import Foundation

extension ItemRowView {
    class ViewModel: ObservableObject {
        let project: Project
        let item: Item

        init(project: Project, item: Item) {
            self.project = project
            self.item = item
        }

        /// The image name of an icon based on a hierarchy of features of an item.
        var iconImageName: String {
            if item.completed {
                return "checkmark.circle.fill"
            } else if item.priority == 3 {
                return "exclamationmark.3"
            } else {
                return "circle"
            }
        }

        /// The colour of an icon based on a hierarchy of features of an item.
        var iconColor: String? {
            if item.completed {
                return project.projectColor
            } else if item.priority == 3 {
                return project.projectColor
            } else {
                return nil
            }
        }

        /// A String to create a "more human" accessibility label for VoiceOver to read.
        var label: String {
            if item.completed {
                return "\(item.itemTitle), completed"
            } else if item.priority == 3 {
                return "\(item.itemTitle), high priority"
            } else {
                return item.itemTitle
            }
        }

        var itemTitle: String {
            item.itemTitle
        }
    }
}
