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
    
    @FetchRequest(entity: Project.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Project.title,
                                                     ascending: true)],
                  predicate: NSPredicate(format: "closed = false")) var projects: FetchedResults<Project>
    
    let items: FetchRequest<Item>
    
    static let tag: String? = "Home"
    
    var rows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")
        
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
                        ItemListView(title: "Up next",
                                     items: items.wrappedValue.prefix(3))
                        
                        ItemListView(title: "More to explore",
                                     items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                Button("Add data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
