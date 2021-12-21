//
//  ItemListView.swift
//  Bulo
//
//  Created by Jake King on 27/10/2021.
//

import SwiftUI

/// A view containing a given header text followed by a given list of items.
struct ItemListView: View {
    /// The header text for the view.
    let title: LocalizedStringKey
    /// The list of items to display.
    @Binding var items: ArraySlice<Item>

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)

            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    ItemListBodyView(item: item)
                }
            }
        }
    }
}
