//
//  SharedProjectsView.swift
//  Bulo
//
//  Created by Jake King on 22/12/2021.
//

import CloudKit
import SwiftUI

struct SharedProjectsView: View {
    static let tag: String? = "community"

    @State private var projects = [SharedProject]()
    @State private var loadState = LoadState.inactive

    var body: some View {
        NavigationView {
            Group {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results.")
                case .success:
                    List(projects) { project in
                        NavigationLink(destination: SharedItemsView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.title)
                                    .font(.headline)

                                Text(project.owner)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Shared Projects")
        }
        .onAppear(perform: fetchSharedProjects)
    }

    func fetchSharedProjects() {
        // Ensure shared projects are fetched from iCloud only once.
        guard loadState == .inactive else {
            return
        }

        loadState = .loading

        // Tell CloudKit what data we're looking for and how to sort it.
        let predicate = NSPredicate(value: true) // CloudKit queries must have a predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Project", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        // Tell CloudKit what attributes we want back.
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "owner", "closed"]
        operation.resultsLimit = 50

        // Convert fetched CKRecord to SharedProject object
        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let title = record["title"] as? String ?? "No title"
            let detail = record["detail"] as? String ?? "No detail"
            let owner = record["owner"] as? String ?? "Anonymous"
            let closed = record["closed"] as? Bool ?? false

            let sharedProject = SharedProject(id: id,
                                              title: title,
                                              detail: detail,
                                              owner: owner,
                                              closed: closed)
            projects.append(sharedProject)

            // Show records as soon as one arrives.
            loadState = .success
        }

        // If projects is empty after all data fetched, set load state to show no results.
        operation.queryCompletionBlock = { _, _ in
            if projects.isEmpty {
                loadState = .noResults
            }
        }

        // Send operation to iCloud.
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedProjectsView()
    }
}
