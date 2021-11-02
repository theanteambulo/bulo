//
//  DefaultDetailView.swift
//  Bulo
//
//  Created by Jake King on 19/10/2021.
//

import SwiftUI

/// Placeholder view for when the user has their device in landscape mode.
struct DefaultDetailView: View {
    var body: some View {
        Text(.landscapePlaceholder)
            .italic()
            .foregroundColor(.secondary)
    }
}

struct DefaultDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultDetailView()
    }
}
