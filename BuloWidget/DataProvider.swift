//
//  DataProvider.swift
//  BuloWidgetExtension
//
//  Created by Jake King on 18/12/2021.
//

import SwiftUI
import WidgetKit

/// Determines how data for our widget is fetched.
struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    items: [Item.example])
    }

    func loadItems() -> [Item] {
        let dataController = DataController()
        let itemRequest = dataController.fetchRequestForTopItems(count: 5)
        return dataController.results(for: itemRequest)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(),
                                items: loadItems())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry =  SimpleEntry(date: Date(),
                                 items: loadItems())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

/// Determines how data for our widget is stored.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}
