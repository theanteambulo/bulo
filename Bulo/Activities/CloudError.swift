//
//  CloudError.swift
//  Bulo
//
//  Created by Jake King on 24/12/2021.
//

import Foundation

struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    var message: String

    init(stringLiteral value: String) {
        self.message = value
    }
}
