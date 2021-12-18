//
//  SimpleWidget.swift
//  BuloWidgetExtension
//
//  Created by Jake King on 18/12/2021.
//

import SwiftUI
import WidgetKit

/// Determines how data for simple widget is presented.
struct BuloWidgetEntryView: View {
    // The view expects to be given one entry to show, which should contain all the information it needs to show itself.
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(.widgetUpNext)
                .font(.headline)

            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text(.widgetNoItems)
            }
        }
    }
}

/// Determines how a simple widget can be configured.
struct SimpleBuloWidget: Widget {
    let kind: String = "SimpleBuloWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BuloWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(Strings.widgetUpNext.localized)
        .description(Strings.widgetTopPrioritySingle.localized)
        .supportedFamilies([.systemSmall])
    }
}

/// Determines how our widget should be previewed inside Xcode.
struct BuloWidget_Previews: PreviewProvider {
    static var previews: some View {
        BuloWidgetEntryView(entry: SimpleEntry(date: Date(),
                                               items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
