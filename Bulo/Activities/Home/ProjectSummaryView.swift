//
//  ProjectSummaryView.swift
//  Bulo
//
//  Created by Jake King on 27/10/2021.
//

import SwiftUI

/// A view containing details of a given project.
struct ProjectSummaryView: View {
    /// The project used to construct this view.
    @ObservedObject var project: Project

    var body: some View {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(project.label)
    }
}

struct ProjectSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSummaryView(project: Project.example)
    }
}
