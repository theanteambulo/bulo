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
            Section(header: Text("Basic Settings")) {
                TextField(NSLocalizedString("Project name",
                                            comment: "Placeholder project name"),
                          text: $title.onChange(update))
                TextField(NSLocalizedString("Description",
                                            comment: "Placeholder project description"),
                          text: $detail.onChange(update))
            }
            
            Section(header: Text("Select Project Colour")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors,
                            id: \.self) { item in
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
                    }
                }
                .padding(.vertical)
            }
            
            Section(footer: Text("Closing a project moves it from the Open to Closed tab. Deleting a project removes it completely and is irreversible.")) {
                Button(project.closed ? "Reopen Project" : "Close Project") {
                    project.closed.toggle()
                    update()
                }
                
                Button("Delete Project") {
                    displayDeleteConfirmationAlert.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $displayDeleteConfirmationAlert) {
            Alert(title: Text("Delete project?"),
                  message: Text("Are you sure you want to delete this project? All the items it contains will also be deleted. This action cannot be undone."),
                  primaryButton: .destructive(Text("Delete"),
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
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
