//
//  ItemRowView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct ItemRowView: View {
    /// The project used to construct this view.
    @ObservedObject var project: Project
    /// The item used to construct this view.
    @ObservedObject var item: Item

    /// A containing a coloured icon based on a hierarchy of features of an item.
    var icon: some View {
        if item.completed {
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(project.projectColor))
        } else if item.priority == 3 {
            return Image(systemName: "exclamationmark.3")
                .foregroundColor(Color(project.projectColor))
        } else {
            return Image(systemName: "circle")
                .foregroundColor(Color(project.projectColor))
        }
    }

    /// A view to create a "more human" accessibility label for VoiceOver to read.
    var label: Text {
        if item.completed {
            return Text("\(item.itemTitle), completed")
        } else if item.priority == 3 {
            return Text("\(item.itemTitle), high priority")
        } else {
            return Text(item.itemTitle)
        }
    }

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }
            .accessibilityLabel(label)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example,
                    item: Item.example)
    }
}
