//
//  SharedItemsView.swift
//  Bulo
//
//  Created by Jake King on 22/12/2021.
//

import CloudKit
import SwiftUI

struct SharedItemsView: View {
    let project: SharedProject

    @State private var items = [SharedItem]()
    @State private var itemsLoadState = LoadState.inactive

    var body: some View {
        List {
            Section {
                switch itemsLoadState {
                case .inactive, .loading:
                    ProgressView()
                case .success:
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)

                            if item.detail.isEmpty == false {
                                Text(item.detail)
                            }
                        }
                    }
                case .noResults:
                    Text("No results.")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear(perform: fetchSharedItems)
    }

    func fetchSharedItems() {
        // Ensure shared items are fetched from iCloud only once.
        guard itemsLoadState == .inactive else {
            return
        }

        itemsLoadState = .loading

        // Tell CloudKit what data we're looking for and how to sort it.
        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID,
                                            action: .none)
        let predicate = NSPredicate(format: "project == %@", reference)
        let sortDescriptor = NSSortDescriptor(key: "title",
                                              ascending: true)
        let query =  CKQuery(recordType: "Item",
                             predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        // Tell CloudKit what attributes we want back.
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "completed"]
        operation.resultsLimit =  50

        // Convert fetched CKRecord to SharedProject object
        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let title = record["title"] as? String ?? "No title"
            let detail = record["detail"] as? String ?? "No detail"
            let completed = record["completed"] as? Bool ?? false

            let sharedItem = SharedItem(id: id,
                                        title: title,
                                        detail: detail,
                                        completed: completed)

            items.append(sharedItem)

            // Show records as soon as one arrives.
            itemsLoadState = .success
        }

        // If projects is empty after all data fetched, set load state to show no results.
        operation.queryCompletionBlock = { _, _ in
            if items.isEmpty {
                itemsLoadState = .noResults
            }
        }

        // Send operation to iCloud.
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}
