//
//  AwardsView.swift
//  Bulo
//
//  Created by Jake King on 20/10/2021.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController

    /// Boolean to indicate whether the award details Alert should be displayed.
    @State private var showingAwardDetails = false
    /// The award selected by the user to view details of.
    @State private var selectedAward = Award.example

    /// Tag value for the Awards tab.
    static let tag: String? = "Awards"

    /// An adaptive grid where each element has a height and width of exactly 90 points.
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 90, maximum: 90))]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 90, height: 90)
                                .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(Text(award.description))
                    }
                }
            }
            .navigationTitle(Text(.awardsTab))
        }
        .alert(isPresented: $showingAwardDetails, content: getAwardAlert)
    }

    /// Provides the color of a given award if the user has earned that award, otherwise returns .secondary.
    /// - Parameter award: The award the user has selected.
    /// - Returns: A Color view with a hue conditional on whether or not the user has earned that award.
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award)
        ? Color(award.color)
        : .secondary.opacity(0.5)
    }

    /// Provides the Alert message to be displayed to the user when they select an award to view details of.
    /// - Parameter award: The award the user has selected.
    /// - Returns: A Text view with the string conditional on whether or not the user has earned that award.
    func label(for award: Award) -> Text {
        Text(
            dataController.hasEarned(award: award)
            ? "Unlocked: \(award.name)"
            : Strings.lockedAlertTitle.localized
        )
    }

    /// Creates the Alert view to be displayed to the user when they select an award to view details of.
    /// - Returns: An Alert view with contents conditional on whether or not the user has earned that award.
    func getAwardAlert() -> Alert {
        if dataController.hasEarned(award: selectedAward) {
            return Alert(
                title: Text("Unlocked: \(selectedAward.name)"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text(.okCallToAction))
            )
        } else {
            return Alert(
                title: Text(.lockedAlertTitle),
                message: Text(selectedAward.description),
                dismissButton: .default(Text(.okCallToAction))
            )
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
