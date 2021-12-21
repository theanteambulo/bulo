//
//  ItemListBodyView.swift
//  Bulo
//
//  Created by Jake King on 27/10/2021.
//

import SwiftUI

/// A view containing a decorative circle coloured the same a given item's parent project, followed by that item's title
/// and detail text if applicable.
struct ItemListBodyView: View {
    /// The item used to construct this view.
    @ObservedObject var item: Item

    var body: some View {
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
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2),
                radius: 5)
    }
}

struct ItemListBodyView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListBodyView(item: Item.example)
    }
}
