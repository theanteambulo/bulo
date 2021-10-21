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
                            ForEach(projects) { project in
                                VStack(alignment: .leading) {
                                    Text("\(project.projectItems.count) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(project.projectTitle)
                                        .font(.title2)
                                        .frame(minWidth: 125,
                                               alignment: .leading)
                                    
                                    ProgressView(value: project.completionAmount)
                                        .accentColor(Color(project.projectColor))
                                }
                                .padding()
                                .background(Color.secondarySystemGroupedBackground)
                                .cornerRadius(5)
                                .shadow(color: Color.black.opacity(0.2),
                                        radius: 5)
                            }
                        }
                        .padding([.horizontal,
                                  .top])
                    }
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
        }
    }
}

//Button("Add Data") {
//    dataController.deleteAll()
//    try? dataController.createSampleData()
//}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
