//
//  AwardsView.swift
//  Bulo
//
//  Created by Jake King on 20/10/2021.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    
    @State private var showingAwardDetails = false
    @State private var selectedAward = Award.example
    
    static let tag: String? = "Awards"
    
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
                                .foregroundColor(dataController.hasEarned(award: award)
                                                 ? Color(award.color)
                                                 : .secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails) {
            if dataController.hasEarned(award: selectedAward) {
                return Alert(title: Text("Unlocked: \(selectedAward.name)"),
                             message: Text(selectedAward.description),
                             dismissButton: .default(Text("OK")))
            } else {
                return Alert(title: Text("Locked"),
                             message: Text(selectedAward.description),
                             dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
