//
//  DataController-Reminders.swift
//  Bulo
//
//  Created by Jake King on 18/12/2021.
//

import UserNotifications

extension DataController {
    /// Add a reminder to a given project.
    /// - Parameters:
    ///   - project: The project to add a reminder to.
    ///   - completion: Handler function to send back any errors that arise during notification work.
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // The hub of UserNotifications framework responsible for reading and writing notifications.
        let center = UNUserNotificationCenter.current()

        // Determine the user's notification settings.
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            // If not already determined, determine the user's settings.
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        // Permission granted, place reminders.
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        // Permission denied, failure.
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            // If already authorised, place reminders by passing in completion closure.
            case .authorized:
                self.placeReminders(for: project,
                                    completion: completion)
            // Failure - call completion handler directly.
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Removes a reminder from a given project.
    /// - Parameter project: The project to remove the reminder from.
    func removeReminders(for project: Project) {
        // Get the project ID.
        let projectID = project.objectID.uriRepresentation().absoluteString

        // The hub of UserNotifications framework responsible for reading and writing notifications.
        let center = UNUserNotificationCenter.current()

        // Remove pending notification requests for the project from the notification center.
        center.removePendingNotificationRequests(withIdentifiers: [projectID])
    }

    /// Requests notification privileges from the user.
    /// - Parameter completion: Handler function to send back any errors that arise during notification work.
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        // The hub of UserNotifications framework responsible for reading and writing notifications.
        let center = UNUserNotificationCenter.current()

        // Request permission to display alert and play a sound, then call completion handler.
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }

    /// Places a single notification for a given project.
    /// - Parameters:
    ///   - project: The project to place a notification for.
    ///   - completion: Handler function to send back any errors that arise during notification work.
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // Dictate the content of the notification.
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle

        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }

        // Define the calendar trigger of the notification - the circumstance under which it is shown.
        let components = Calendar.current.dateComponents([.hour, .minute],
                                                         from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Wrap the content and trigger up in a single notification with a unique ID.
        let projectID = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(
            identifier: projectID,
            content: content,
            trigger: trigger
        )

        // Send notification request to iOS.
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    // Notification successfully scheduled.
                    completion(true)
                } else {
                    // Notification not scheduled.
                    completion(false)
                }
            }
        }
    }
}
