//
//  ServerList.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-22.
//

import SwiftUI

/// An editable list of all the user's configured servers.
struct ServerList: View {
    var body: some View {
        List {
            Label("Hello, world!", systemImage: "circle.fill")
        }
        .navigationTitle("Servers")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Previews

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerList()
        }
        .navigationViewStyle(.stack)
    }
}
