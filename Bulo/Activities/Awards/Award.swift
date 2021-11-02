//
//  Award.swift
//  Bulo
//
//  Created by Jake King on 20/10/2021.
//

import Foundation

/// A structure that stores awards to be earned by the user as they use the app more.
struct Award: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let description: String
    let color: String
    let criterion: String
    let value: Int
    let image: String

    // The allAwards property is useful as we load awards in more than one place. Reminder that static
//    constants can access each other in Swift because they're created lazily.
    static let allAwards = Bundle.main.decode([Award].self, from: "Awards.json")
    static let example = allAwards[0]
}
