//
//  NavigationSource.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// A primary navigation source within a `MainController` for navigating between `MainTab`s.
protocol NavigationSource: UIViewController {
    /// The delegate for this navigation source to publish its events to.
    var navigationSourceDelegate: NavigationSourceDelegate? { get set }

    /// Select the given tab within this navigation source.
    /// - Parameter tab: The tab to select.
    func selectTab(_ tab: MainTab)
}
