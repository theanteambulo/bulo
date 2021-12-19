//
//  ComplexWidget.swift
//  BuloWidgetExtension
//
//  Created by Jake King on 19/12/2021.
//

import SwiftUI
import WidgetKit

/// Determines how data for complex widget is presented.
struct BuloWidgetMultipleEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.sizeCategory) var sizeCategory

    var entry: Provider.Entry

    var items: ArraySlice<Item> {
        let itemCount: Int

        switch widgetFamily {
        case .systemSmall:
            itemCount = 1
        case .systemLarge:
            if sizeCategory < .extraExtraLarge {
                itemCount = 5
            } else {
                itemCount = 4
            }
        default:
            if sizeCategory < .extraLarge {
                itemCount = 3
            } else {
                itemCount = 2
            }
        }

        return entry.items.prefix(itemCount)
    }

    var body: some View {
        VStack(spacing: 5) {
            ForEach(items) { item in
                HStack {
                    Color(item.project?.color ?? "Light Blue")
                        .frame(width: 5)
                        .clipShape(Capsule())

                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.headline)
                            .layoutPriority(1)

                        if let projectTitle = item.project?.projectTitle {
                            Text(projectTitle)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding(15)
    }
}

/// Determines how a complex widget is configured.
struct ComplexBuloWidget: Widget {
    let kind: String = "ComplexBuloWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BuloWidgetMultipleEntryView(entry: entry)
        }
        .configurationDisplayName(Strings.widgetUpNext.localized)
        .description(Strings.widgetTopPriorityMultiple.localized)
    }
}

/// Determines how our widget should be previewed inside Xcode.
struct ComplexBuloWidget_Previews: PreviewProvider {
    static var previews: some View {
        BuloWidgetMultipleEntryView(entry: SimpleEntry(date: Date(),
                                               items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
