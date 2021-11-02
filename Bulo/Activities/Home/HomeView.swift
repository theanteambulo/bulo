//
//  HomeView.swift
//  Bulo
//
//  Created by Jake King on 14/10/2021.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController

    /// The user's currently open projects.
    @FetchRequest(entity: Project.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Project.title,
                                                     ascending: true)],
                  predicate: NSPredicate(format: "closed = false")
    ) var projects: FetchedResults<Project>

    /// The user's highest-priority, incomplete items.
    let items: FetchRequest<Item>

    /// Tag value for the Home tab.
    static let tag: String? = "Home"

    /// A grid with a single row 100 points in size.
    var rows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects. As
    // part of the managed object subclass that Xcode generates, we get a fetchRequest() method that creates
    // an NSFetchRequest to read that class. This causes problems in testing because Core Data doesn't know
    // where to find the entity description. For this reason, the NSFetchRequest for items is created manually.
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and,
                                                    subpredicates: [completedPredicate,
                                                                    openPredicate])

        request.predicate = compoundPredicate

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority,
                             ascending: false)
        ]

        request.fetchLimit = 10

        items = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows) {
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal,
                                  .top])
                        .fixedSize(horizontal: false,
                                   vertical: true)
                    }

                    VStack(alignment: .leading) {
                        ItemListView(
                            title: Strings.upNextSectionHeader.localized,
                            items: items.wrappedValue.prefix(3)
                        )

                        ItemListView(
                            title: Strings.moreToExploreSectionHeader.localized,
                            items: items.wrappedValue.dropFirst(3)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle(Text(.homeTab))
            .toolbar {
                Button("Add data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }

            DefaultDetailView()

        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
