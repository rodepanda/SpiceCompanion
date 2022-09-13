//
//  ConnectionView.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-12.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// The root view presented when the user successfully connects to a server.
struct ConnectionView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The currently selected tab within this view.
    @State private var selectedTab: ConnectionTab? = .cards

    var body: some View {
        if horizontalSizeClass == .regular {
            // present a sidebar in a master/detail configuration in the regular
            // size class
            NavigationView {
                ConnectionSidebarView(selection: $selectedTab)

                Group {
                    switch selectedTab {
                    case .cards:   CardsView()
                    case .keypad:  KeypadView()
                    case .patches: PatchesView()
                    case .system:  SystemView()
                    default:       EmptyView()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.columns)
        }
        else {
            // present tabs in the compact size class
            ConnectionTabsView(selection: $selectedTab)
        }
    }
}

// MARK: - Previews

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
            .previewInterfaceOrientation(.landscapeRight)
            .previewDisplayName("Landscape")

        ConnectionView()
            .previewInterfaceOrientation(.portrait)
            .previewDisplayName("Portrait")
    }
}
