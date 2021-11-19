//
//  ItemRowView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct ItemRowView: View {
    @StateObject var viewModel: ViewModel

    /// The item used to construct this view.
    @ObservedObject var item: Item

    init(project: Project, item: Item) {
        let viewModel = ViewModel(project: project, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)

        self.item = item
    }

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(viewModel.itemTitle)
            } icon: {
                Image(systemName: viewModel.iconImageName)
                    .foregroundColor(viewModel.iconColor.map { Color($0) } ?? .clear)
            }
            .accessibilityLabel(viewModel.label)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example,
                    item: Item.example)
    }
}
