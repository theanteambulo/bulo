//
//  EditItemView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct EditItemView: View {
    let item: Item

    @EnvironmentObject var dataController: DataController

    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool

    init(item: Item) {
        self.item = item

        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettingsSectionHeader)) {
                TextField(Strings.itemName.localized,
                          text: $title.onChange(update))
                TextField(Strings.itemDescription.localized,
                          text: $detail.onChange(update))
            }

            Section(header: Text(Strings.itemPriority.localized)) {
                Picker(Strings.itemPriority.localized,
                       selection: $priority.onChange(update)) {
                    Text(.itemPriorityLow)
                        .tag(1)
                    Text(.itemPriorityMedium)
                        .tag(2)
                    Text(.itemPriorityHigh)
                        .tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section {
                Toggle(Strings.markCompletedToggleLabel.localized,
                       isOn: $completed.onChange(update))
            }
        }
        .navigationTitle(Text(.editItem))
        .onDisappear(perform: dataController.save)
    }

    func update() {
        item.project?.objectWillChange.send()

        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(item: Item.example)
    }
}
