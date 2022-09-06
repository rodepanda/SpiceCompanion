//
//  NavigationSourceDelegate.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import UIKit

/// A delegate for receiving events from a `NavigationSource`.
protocol NavigationSourceDelegate: AnyObject {
    /// Called to inform the delegate that the navigation source has selected the given tab.
    /// - Parameter navigationSource: The navigation source publishing this event.
    /// - Parameter tab: The newly selected tab.
    func navigationSource(_ navigationSource: NavigationSource, didSelectTab tab: MainTab)
}
