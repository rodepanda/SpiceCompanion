//
//  ConnectionSidebar.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-12.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// The view for presenting a sidebar within a `ConnectionView`.
struct ConnectionSidebarView: View {

    /// The currently selected tab within this view, if any.
    let selection: Binding<ConnectionTab?>

    var body: some View {
        List(selection: selection) {
            Section("Spice") {
                ForEach(ConnectionTab.allCases, id: \.self) { tab in
                    Label(tab.contents.title, systemImage: tab.contents.outlinedIcon)
                        .tag(tab)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Sidebar") //TODO: server in environment
    }
}

// MARK: - Previews

struct ConnectionSidebar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConnectionSidebarView(selection: .constant(.cards))
            Text("Placeholder") //force a master/detail view
        }
        .previewInterfaceOrientation(.landscapeRight)
    }
}
