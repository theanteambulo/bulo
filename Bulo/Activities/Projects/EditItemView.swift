//
//  EditItemView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct EditItemView: View {
    /// The item used to construct this view.
    let item: Item

    @EnvironmentObject var dataController: DataController

    /// The title given to the item by the user.
    @State private var title: String
    /// The description given to the item by the user.
    @State private var detail: String
    /// The priority level given to the item by the user.
    @State private var priority: Int
    /// The completion status given to the item by the user.
    @State private var completed: Bool

    // When we have multiple @StateObject properties that rely on each other, they must get created
    // in their own customer initialiser.
    init(item: Item) {
        self.item = item

        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }

    // The extension on Binding is used extensively throughout this view to avoid the excessive and
    // repetitive use of the Swift .onChange modifier.
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
        .onDisappear(perform: save)
    }

    /// Synchronize the @State properties of EditItemView with their Core Data equivalents in whichever Item
    /// object is being edited and announce the change to property wrappers observing it.
    func update() {
        item.project?.objectWillChange.send()

        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }

    /// Ensures the item will be reindexed in Spotlight and changed data written back to Core Data when the user
    /// leaves the screen.
    func save() {
        dataController.update(item)
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(item: Item.example)
    }
}
