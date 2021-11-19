//
//  HomeView.swift
//  Bulo
//
//  Created by Jake King on 14/10/2021.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: ViewModel

    /// Tag value for the Home tab.
    static let tag: String? = "Home"

    /// A grid with a single row 100 points in size.
    var rows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal,
                                  .top])
                        .fixedSize(horizontal: false,
                                   vertical: true)
                    }

                    VStack(alignment: .leading) {
                        ItemListView(
                            title: Strings.upNextSectionHeader.localized,
                            items: viewModel.upNext
                        )

                        ItemListView(
                            title: Strings.moreToExploreSectionHeader.localized,
                            items: viewModel.moreToExplore
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle(Text(.homeTab))
            .toolbar {
                Button("Add data", action: viewModel.addSampleData)
            }

            DefaultDetailView()

        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
