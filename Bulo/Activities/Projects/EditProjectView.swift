//
//  EditProjectView.swift
//  Bulo
//
//  Created by Jake King on 16/10/2021.
//

import CloudKit
import CoreHaptics
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
    /// A Boolean to indicate whether or not the user wants to be reminded about this project or not.
    @State private var remindMe: Bool
    /// The time that the user wants to be reminded about this project.
    @State private var reminderTime: Date
    /// A Boolean to indicate whether or not the notification error Alert is being displayed or not.
    @State private var displayNotificationError = false
    /// A Boolean to indicate whether or not the delete confirmation Alert is being displayed or not.
    @State private var displayDeleteConfirmationAlert = false
    /// An instance of CHHapticEngine responsible for spinning up the Taptic Engine.
    @State private var hapticEngine = try? CHHapticEngine()

    // When we have multiple @StateObject properties that rely on each other, they must get created
    // in their own customer initialiser.
    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)

        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }

    var uploadToiCloudToolbarItem: some ToolbarContent {
        ToolbarItem {
            Button {
                // Tell CloudKit the records we want to modify.
                let records = project.prepareCloudRecords()
                let operation = CKModifyRecordsOperation(recordsToSave: records,
                                                         recordIDsToDelete: nil)

                // Write out all data, overwriting everything no matter what.
                operation.savePolicy = .allKeys

                // Completion closure to run when all records are saved. Passed the records made, records deleted and
                // any errors that occurred.
                operation.modifyRecordsCompletionBlock = { _, _, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }

                // Send data to iCloud.
                CKContainer.default().publicCloudDatabase.add(operation)
            } label: {
                Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
            }
        }
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettingsSectionHeader)) {
                TextField(Strings.projectName.localized,
                          text: $title.onChange(update))
                TextField(Strings.projectDescription.localized,
                          text: $detail.onChange(update))
            }

            Section(header: Text(.projectRemindersSectionHeader)) {
                Toggle(Strings.showReminders.localized,
                       isOn: $remindMe.animation().onChange(update))
                    .alert(isPresented: $displayNotificationError) {
                        Alert(
                            title: Text(.projectRemindersErrorTitle),
                            message: Text(.projectRemindersErrorMessage),
                            primaryButton: .default(Text(.settingsButtonText),
                                                    action: showAppSettings),
                            secondaryButton: .cancel()
                        )
                    }

                if remindMe {
                    DatePicker(
                        Strings.reminderTime.localized,
                        selection: $reminderTime.onChange(update),
                        displayedComponents: .hourAndMinute
                    )
                }
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
                       : Strings.closeProject.localized,
                       action: toggleClosed
                )

                Button(Strings.deleteProject.localized) {
                    displayDeleteConfirmationAlert.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle(Text(.editProject))
        .toolbar {
            uploadToiCloudToolbarItem
        }
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

        if remindMe {
            project.reminderTime = reminderTime

            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false

                    displayNotificationError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }

    /// Toggles the project's closed property and provides haptic feedback to the user if they have closed the project.
    func toggleClosed() {
        project.closed.toggle()

        if project.closed {
            do {
                try hapticEngine?.start()

                // Haptic event parameters.
                let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                // Haptic event control points.
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                // Use parameter curve to control haptic intensity.
                let buzzFadeParameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                // Create haptic events to play in sequence.
                let tapEvent = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [hapticSharpness, hapticIntensity],
                    relativeTime: 0
                )

                let buzzFadeEvent = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [hapticSharpness, hapticIntensity],
                    relativeTime: 0.125,
                    duration: 1
                )

                // Create pattern in which to play events.
                let pattern = try CHHapticPattern(events: [tapEvent, buzzFadeEvent],
                                                  parameterCurves: [buzzFadeParameter])

                // Create a player from the pattern and make it play from the start.
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
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
