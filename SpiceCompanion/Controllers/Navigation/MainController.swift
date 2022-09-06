//
//  MainController.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// The main view controller at the root of the hierarchy after successfully connecting to a server.
class MainController: UISplitViewController {

    /// All the main tabs within this controller.
    private let tabs = [
        MainTab(
            name: "Cards",
            filledIcon: "creditcard.fill",
            outlinedIcon: "creditcard",
            storyboard: "Cards"
        ),
        MainTab(
            name: "Keypad",
            filledIcon: "square.grid.3x3.fill",
            outlinedIcon: "square.grid.3x3",
            storyboard: "Keypad"
        ),
        MainTab(
            name: "Mirror",
            filledIcon: "rectangle.fill.on.rectangle.fill",
            outlinedIcon: "rectangle.on.rectangle",
            storyboard: "Mirror"
        ),
        MainTab(
            name: "Patches",
            filledIcon: "puzzlepiece.extension.fill",
            outlinedIcon: "puzzlepiece.extension",
            storyboard: "Patches"
        ),
        MainTab(
            name: "System",
            filledIcon: "memorychip.fill",
            outlinedIcon: "memorychip",
            storyboard: "Settings"
        ),
    ]

    init() {
        super.init(style: .doubleColumn)

        let sidebar = SidebarController(tabs: tabs)
        let sidebarNavigationController = UINavigationController(rootViewController: sidebar)
        sidebarNavigationController.navigationBar.prefersLargeTitles = true

        let tabs = TabsController(tabs: tabs)
        setViewController(sidebarNavigationController, for: .primary)
        setViewController(tabs, for: .secondary)
        setViewController(tabs, for: .compact)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
