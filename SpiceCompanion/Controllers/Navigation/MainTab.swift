//
//  MainTab.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// A tab at the root of a `MainController`.
struct MainTab: Hashable {

    /// The storyboard containing this tab's view controller as its initial view controller.
    private let storyboard: UIStoryboard

    /// The display name of this tab.
    let name: String

    /// The filled variant of this tab's icon.
    let filledIcon: UIImage

    /// The outlined variant of this tab's icon.
    let outlinedIcon: UIImage

    init(name: String, filledIcon filledSystemName: String, outlinedIcon outlinedSystemName: String, storyboard storyboardName: String) {
        self.name = name
        self.filledIcon = UIImage(systemName: filledSystemName)!
        self.outlinedIcon = UIImage(systemName: outlinedSystemName)!
        self.storyboard = UIStoryboard(name: storyboardName, bundle: .main)
    }

    /// Instantiate a new instance of this tab's view controller.
    /// - Returns: A new instance of this tab's view controller.
    func instantiateViewController() -> UIViewController {
        return storyboard.instantiateInitialViewController()!
    }
}
