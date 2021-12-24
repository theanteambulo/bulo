//
//  SharedItemsView.swift
//  Bulo
//
//  Created by Jake King on 22/12/2021.
//

import CloudKit
import SwiftUI

struct SharedItemsView: View {
    let project: SharedProject

    /// The user's username.
    @AppStorage("username") var username: String?

    /// The array of SharedItem objects fetched from iCloud.
    @State private var items = [SharedItem]()
    /// Tracks whether item data has been fetched from iCloud or not.
    @State private var itemsLoadState = LoadState.inactive
    /// The array of ChatMessage objects fetched from iCloud.
    @State private var messages = [ChatMessage]()
    /// Tracks whether message data has been fetched from iCloud or not.
    @State private var messagesLoadState = LoadState.inactive
    /// Boolean to indicate whether the Sign in with Apple Sheet is being displayed or not.
    @State private var showingSignInWithAppleSheet = false
    /// The text the user has currently typed.
    @State private var newChatText = ""

    /// The view which allows users to write comments on a project.
    @ViewBuilder var messagesFooter: some View {
        if username == nil {
            Button("Sign in to comment", action: signIn)
                .frame(maxWidth: .infinity)
        } else {
            VStack {
                TextField("Enter your message", text: $newChatText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textCase(nil)

                Button(action: sendChatMessage) {
                    Text("Send")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
            }
        }
    }

    var body: some View {
        List {
            Section {
                switch itemsLoadState {
                case .inactive, .loading:
                    ProgressView()
                case .success:
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)

                            if item.detail.isEmpty == false {
                                Text(item.detail)
                            }
                        }
                    }
                case .noResults:
                    Text("No results.")
                }
            }

            Section(
                header: Text("Chat about this project…"),
                footer: messagesFooter
            ) {
                if messagesLoadState == .success {
                    ForEach(messages) { message in
                        VStack(alignment: .leading) {
                            Text("\(message.from)")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            Text("\(message.text)")
                                .multilineTextAlignment(.leading)

                            HStack {
                                Spacer()

                                Text(formatDateTime(message.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear {
            fetchSharedItems()
            fetchChatMessages()
        }
        .sheet(isPresented: $showingSignInWithAppleSheet,
               content: SignInView.init)
    }

    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: date)
    }

    func fetchSharedItems() {
        // Ensure shared items are fetched from iCloud only once.
        guard itemsLoadState == .inactive else {
            return
        }

        itemsLoadState = .loading

        // Tell CloudKit what data we're looking for and how to sort it.
        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID,
                                            action: .none)
        let predicate = NSPredicate(format: "project == %@", reference)
        let sortDescriptor = NSSortDescriptor(key: "title",
                                              ascending: true)
        let query =  CKQuery(recordType: "Item",
                             predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        // Tell CloudKit what attributes we want back.
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "completed"]
        operation.resultsLimit =  50

        // Convert fetched CKRecord to SharedProject object.
        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let title = record["title"] as? String ?? "No title"
            let detail = record["detail"] as? String ?? "No detail"
            let completed = record["completed"] as? Bool ?? false

            let sharedItem = SharedItem(id: id,
                                        title: title,
                                        detail: detail,
                                        completed: completed)

            items.append(sharedItem)

            // Show records as soon as one arrives.
            itemsLoadState = .success
        }

        // If projects is empty after all data fetched, set load state to show no results.
        operation.queryCompletionBlock = { _, _ in
            if items.isEmpty {
                itemsLoadState = .noResults
            }
        }

        // Send operation to iCloud.
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func fetchChatMessages() {
        // Ensure chat messages are fetched from iCloud only once.
        guard messagesLoadState == .inactive else {
            return
        }

        messagesLoadState = .loading

        // Tell CloudKit what data we're looking for and how to sort it.
        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let predicate = NSPredicate(format: "project = %@", reference)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Message", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        // Tell CloudKit what attributes we want back.
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["from", "text", "date"]

        // Convert fetched CKRecord into ChatMessage object.
        operation.recordFetchedBlock = { record in
            let message = ChatMessage(from: record)
            messages.append(message)

            // Show records as soon as one arrives.
            messagesLoadState = .success
        }

        // If projects is empty after all data fetched, set load state to show no results.
        operation.queryCompletionBlock = { _, _ in
            if messages.isEmpty {
                messagesLoadState = .noResults
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }

    /// Toggles Boolean controlling whether the Sign in with Apple view is displayed.
    func signIn() {
        showingSignInWithAppleSheet = true
    }

    /// Ensures the user's message meets certain criteria before sending it to iCloud.
    func sendChatMessage() {
        // Trim whitespaces and newlines from the text.
        let text = newChatText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Ensure the text is meaningful - having at least 2 characters.
        guard text.count >= 2 else {
            return
        }

        // Ensure the user has a username.
        guard let username = username else {
            return
        }

        // Create "Message" record with text and username, plus reference to the project.
        let message = CKRecord(recordType: "Message")
        message["from"] = username
        message["text"] = text

        let projectID = CKRecord.ID(recordName: project.id)
        message["project"] = CKRecord.Reference(recordID: projectID,
                                                action: .deleteSelf)

        // Take a copy and clear it to ensure UI updates.
        let backupChatText = newChatText
        newChatText = ""

        // Send the CKRecord object to iCloud to be saved.
        CKContainer.default().publicCloudDatabase.save(message) { record, error in
            if let error = error {
                // Show the error and revert newChatText if something went wrong.
                print(error.localizedDescription)
                newChatText = backupChatText
            } else if let record = record {
                // Append the user's message to messages array on success.
                let message = ChatMessage(from: record)
                messages.append(message)
            }
        }
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}
