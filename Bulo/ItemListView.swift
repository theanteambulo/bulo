//
//  ItemListView.swift
//  Bulo
//
//  Created by Jake King on 27/10/2021.
//

import SwiftUI

struct ItemListView: View {
    let title: LocalizedStringKey
    let items: FetchedResults<Item>.SubSequence

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
                    ItemListViewBody(item: item)
                }
            }
        }
    }
}

// struct ItemListView_Previews: PreviewProvider {
//     static var previews: some View {
//         ItemListView()
//     }
// }
