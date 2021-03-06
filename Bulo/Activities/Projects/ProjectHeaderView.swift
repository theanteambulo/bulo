//
//  ProjectHeaderView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct ProjectHeaderView: View {
    /// The project used to construct this view
    @ObservedObject var project: Project

    var body: some View {
        HStack {
            NavigationLink(destination: EditProjectView(project: project)) {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
            }
            .accessibilityLabel(Text(project.projectTitle))

            Spacer()

            VStack(alignment: .leading) {
                Text(project.projectTitle)

                ProgressView(value: project.completionAmount)
                    .accentColor(Color(project.projectColor))
            }
        }
        .padding(.bottom,
                 10)
        .accessibilityElement(children: .combine)
    }
}

struct ProjectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectHeaderView(project: Project.example)
    }
}
