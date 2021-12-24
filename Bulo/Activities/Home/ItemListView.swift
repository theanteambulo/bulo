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
                    HStack(spacing: 20) {
                        Circle()
                            .stroke(Color(item.project?.projectColor ?? "Light Blue"),
                                    lineWidth: 3)
                            .frame(width: 44,
                                   height: 44)

                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.headline)
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)

                            if item.itemDetail.isEmpty == false {
                                Text(item.itemDetail)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }

                            Text(item.project?.projectTitle ?? "No title")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2),
                            radius: 5)
                }
            }
        }
    }
}
