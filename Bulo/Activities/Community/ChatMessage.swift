//
//  ChatMessage.swift
//  Bulo
//
//  Created by Jake King on 24/12/2021.
//

import CloudKit

struct ChatMessage: Identifiable {
    let id: String
    let from: String
    let text: String
    let date: Date
}

// Using an extension to add custom initialiser allows us to keep the memberwise
// initialiser too.
extension ChatMessage {
    init(from record: CKRecord) {
        id = record.recordID.recordName
        from = record["from"] as? String ?? "Anonymous"
        text = record["text"] as? String ?? "No message"
        date = record.creationDate ?? Date()
    }
}
