//
//  SharedItem.swift
//  Bulo
//
//  Created by Jake King on 22/12/2021.
//

import Foundation

struct SharedItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let completed: Bool

    static let example = SharedItem(id: "1",
                                    title: "Example",
                                    detail: "Detail",
                                    completed: false)
}
