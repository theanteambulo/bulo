//
//  HomeView.swift
//  Bulo
//
//  Created by Jake King on 14/10/2021.
//

import CoreData
import CoreSpotlight
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
                // Check and unwrap viewModel.selectedItem. The navigation link only exists when something is selected.
                if let item = viewModel.selectedItem {
                    // NavigationLink only triggers when something changes due to tag and selection.
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                    )
                    // The id of the item showing, ensuring the view stays up to date even if the item changes.
                    .id(item)
                }

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
                            items: $viewModel.upNext
                        )

                        ItemListView(
                            title: Strings.moreToExploreSectionHeader.localized,
                            items: $viewModel.moreToExplore
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle(Text(.homeTab))
            .toolbar {
                Button("Reset", action: viewModel.dataController.deleteAll)
            }
            .onContinueUserActivity(CSSearchableItemActionType,
                                    perform: loadSpotlightItem)

            DefaultDetailView()

        }
    }

    /// Finds and passes the unique identifier from Spotlight to the view model to select.
    /// - Parameter userActivity: Any type of user activity.
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        // Finds the unique identifier of the item inside the userInfo dictionary.
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            // Passes the unique identifier to the view model to select the item.
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
