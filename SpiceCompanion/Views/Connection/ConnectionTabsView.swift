//
//  ConnectionTabsView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-12.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// The view for presenting a tab bar within a `ConnectionView`.
struct ConnectionTabsView: View {

    /// The currently selected tab within this view, if any.
    let selection: Binding<ConnectionTab?>

    var body: some View {
        TabView(selection: selection) {
            ForEach(ConnectionTab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .cards:   CardsView()
                    case .keypad:  KeypadView()
                    case .patches: PatchesView()
                    case .system:  SystemView()
                    }
                }
                .tabItem {
                    Label(tab.contents.title, systemImage: tab.contents.filledIcon)
                }
                .tag(tab as ConnectionTab?)
            }
        }
    }
}

// MARK: - Previews

struct ConnectionTabs_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionTabsView(selection: .constant(.cards))
    }
}
