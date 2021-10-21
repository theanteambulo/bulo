//
//  HomeView.swift
//  Bulo
//
//  Created by Jake King on 14/10/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    
    static let tag: String? = "Home"

    var body: some View {
        NavigationView {
            ScrollView {
                
            }
            .background(Color.systemGroupedBackground)
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
