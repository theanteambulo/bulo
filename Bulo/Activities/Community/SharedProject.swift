//
//  SharedProject.swift
//  Bulo
//
//  Created by Jake King on 22/12/2021.
//

import Foundation

struct SharedProject: Identifiable {
    let id: String
    let title: String
    let detail: String
    let owner: String
    let closed: Bool

    static let example = SharedProject(id: "1",
                                       title: "Example",
                                       detail: "Detail",
                                       owner: "theanteambulo",
                                       closed: false)
}
