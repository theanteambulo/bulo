//
//  ItemRowView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct ItemRowView: View {
    @ObservedObject var project: Project
    @ObservedObject var item: Item
    
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
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example,
                    item: Item.example)
    }
}
