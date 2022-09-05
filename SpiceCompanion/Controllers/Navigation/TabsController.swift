//
//  TabsController.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// The view controller containing the different tabs within a `MainController`.
class TabsController: UITabBarController {

    init(tabs: [MainTab]) {
        super.init(nibName: nil, bundle: nil)
        setViewControllers(tabs.enumerated().map { index, tab in
            let viewController = tab.instantiateViewController()
            viewController.tabBarItem = UITabBarItem(title: tab.name, image: tab.filledIcon, tag: index)
            return viewController
        }, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
