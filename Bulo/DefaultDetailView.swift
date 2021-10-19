//
//  DefaultDetailView.swift
//  Bulo
//
//  Created by Jake King on 19/10/2021.
//

import SwiftUI

struct DefaultDetailView: View {
    var body: some View {
        Text("Please select something from the menu to begin.")
            .italic()
            .foregroundColor(.secondary)
    }
}

struct DefaultDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultDetailView()
    }
}
