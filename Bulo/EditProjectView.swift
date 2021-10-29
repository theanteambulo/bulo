//
//  EditProjectView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import SwiftUI

struct EditProjectView: View {
    let project: Project
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataController: DataController

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var displayDeleteConfirmationAlert = false

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
        .navigationTitle(Strings.editProject.localized)
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $displayDeleteConfirmationAlert) {
            Alert(title: Text(.deleteProjectAlertTitle),
                  message: Text(.deleteProjectAlertMessage),
                  primaryButton: .destructive(Text(.deleteCallToAction),
                                              action: delete),
                  secondaryButton: .cancel())
        }
    }

    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }

    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    func colourButton(for item: String) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color(item))
                .aspectRatio(1,
                             contentMode: .fit)

            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
                ? [.isButton, .isSelected]
                : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
