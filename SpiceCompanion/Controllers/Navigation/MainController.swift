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
//        MainTab(
//            name: "Mirror",
//            filledIcon: "rectangle.fill.on.rectangle.fill",
//            outlinedIcon: "rectangle.on.rectangle",
//            storyboard: "Mirror"
//        ),
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
            storyboard: "System"
        ),
    ]

    /// The sidebar of this controller.
    private let sidebarController: SidebarController

    /// The tabs of this controller.
    private let tabsController: TabsController

    init() {
        sidebarController = SidebarController(tabs: tabs)
        tabsController = TabsController(tabs: tabs)
        super.init(style: .doubleColumn)
        sidebarController.navigationSourceDelegate = self
        tabsController.navigationSourceDelegate = self

        // wrap the sidebar in a navigation controller for a navigation bar
        let sidebarNavigationController = UINavigationController(rootViewController: sidebarController)
        sidebarNavigationController.navigationBar.prefersLargeTitles = true

        setViewController(sidebarNavigationController, for: .primary)
        setViewController(tabsController, for: .secondary)
        setViewController(tabsController, for: .compact)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // toggle the tab bar depending on if the sidebar is available
        tabsController.tabBar.isHidden = traitCollection.horizontalSizeClass != .compact
    }
}

// MARK: - NavigationSourceDelegate

extension MainController: NavigationSourceDelegate {
    func navigationSource(_ navigationSource: NavigationSource, didSelectTab tab: MainTab) {
        // sync selection between the tabs and sidebar
        if navigationSource == sidebarController {
            tabsController.selectTab(tab)
        }
        else if navigationSource == tabsController {
            sidebarController.selectTab(tab)
        }
    }
}
