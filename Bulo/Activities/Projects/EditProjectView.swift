//
//  EditProjectView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct EditProjectView: View {
    /// The project used to construct this view.
    @ObservedObject var project: Project
    /// An adaptive grid with a minimum height and width of 44 points.
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataController: DataController

    /// The title given to the project by the user.
    @State private var title: String
    /// The description given to the project by the user.
    @State private var detail: String
    /// The colour given to the project by the user.
    @State private var color: String
    /// A Boolean to indicate whether or not the delete confirmation Alert is being displayed or not.
    @State private var displayDeleteConfirmationAlert = false

    // When we have multiple @StateObject properties that rely on each other, they must get created
    // in their own customer initialiser.
    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettingsSectionHeader)) {
                TextField(Strings.projectName.localized,
                          text: $title.onChange(update))
                TextField(Strings.projectDescription.localized,
                          text: $detail.onChange(update))
            }

            Section(header: Text(.projectColorSectionHeader)) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors,
                            id: \.self,
                            content: colourButton)
                }
                .padding(.vertical)
            }

            Section(footer: Text(.warningFooter)) {
                Button(project.closed
                       ? Strings.reopenProject.localized
                       : Strings.closeProject.localized) {
                    project.closed.toggle()
                    update()
                }

                Button(Strings.deleteProject.localized) {
                    displayDeleteConfirmationAlert.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle(Text(.editProject))
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $displayDeleteConfirmationAlert) {
            Alert(title: Text(.deleteProjectAlertTitle),
                  message: Text(.deleteProjectAlertMessage),
                  primaryButton: .destructive(Text(.deleteCallToAction),
                                              action: delete),
                  secondaryButton: .cancel())
        }
    }

    /// Synchronize the @State properties of EditProjectView with their Core Data equivalents in whichever Project
    /// object is being edited.
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }

    /// Delete the Project object currently being edited from the Core Data context.
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    /// Produces a coloured button for a given project color.
    /// - Parameter color: A project color.
    /// - Returns: A circular, tappable ZStack containing a conditional icon when that color is selected.
    func colourButton(for buttonColor: String) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color(buttonColor))
                .aspectRatio(1,
                             contentMode: .fit)

            if buttonColor == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = buttonColor
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            buttonColor == color
                ? [.isButton, .isSelected]
                : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(buttonColor))
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
