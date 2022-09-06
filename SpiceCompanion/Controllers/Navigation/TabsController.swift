//
//  TabsController.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// The view controller containing the different tabs within a `MainController`.
class TabsController: UITabBarController, NavigationSource {

    /// All the tabs within this controller.
    private let tabs: [MainTab]

    weak var navigationSourceDelegate: NavigationSourceDelegate?

    init(tabs: [MainTab]) {
        self.tabs = tabs
        super.init(nibName: nil, bundle: nil)

        // map the given tabs to tab bar items
        setViewControllers(tabs.enumerated().map { index, tab in
            let viewController = tab.instantiateViewController()
            viewController.tabBarItem = UITabBarItem(title: tab.name, image: tab.filledIcon, tag: index)
            return viewController
        }, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // send out the initial event for the default selected tab
        tabBar(tabBar, didSelect: tabBar.selectedItem!)
    }
}

// MARK: - NavigationSource

extension TabsController {
    func selectTab(_ tab: MainTab) {
        guard let index = tabs.firstIndex(of: tab) else {
            return
        }

        selectedViewController = viewControllers![index]
    }
}

// MARK: - UITabBarDelegate

extension TabsController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tab = tabs[item.tag]
        navigationSourceDelegate?.navigationSource(self, didSelectTab: tab)
    }
}
