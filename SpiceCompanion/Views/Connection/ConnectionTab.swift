//
//  ConnectionTab.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-12.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import SwiftUI

/// A single tab that can be navigated to within a `ConnectionView`.
enum ConnectionTab: CaseIterable {

    /// The tab for managing digital NFC cards.
    case cards

    /// The tab for controlling the keypad.
    case keypad

    /// The tab for managing memory patches.
    case patches

    /// The tab for information about and control of the system.
    case system

    /// The contents of this tab.
    var contents: Contents {
        switch self {
        case .cards:
            return Contents(
                title: "Cards",
                outlinedIcon: "creditcard",
                filledIcon: "creditcard.fill"
            )
        case .keypad:
            return Contents(
                title: "Keypad",
                outlinedIcon: "square.grid.3x3",
                filledIcon: "square.grid.3x3.fill"
            )
        case .patches:
            return Contents(
                title: "Patches",
                outlinedIcon: "puzzlepiece.extension",
                filledIcon: "puzzlepiece.extension.fill"
            )
        case .system:
            return Contents(
                title: "System",
                outlinedIcon: "memorychip",
                filledIcon: "memorychip.fill"
            )
        }
    }
}

extension ConnectionTab {
    /// Information about the contents of a single tab.
    struct Contents {

        /// The display title of the tab.
        let title: String

        /// The name of the system image that this tab uses for the outlined variant of its icon.
        let outlinedIcon: String

        /// The name of the system image that this tab uses for the filled variant of its icon.
        let filledIcon: String
    }
}
