//
//  ServerFormDelegate.swift
//  SpiceCompanion
//
//  Created by marika on 2022-09-05.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import Foundation

/// A delegate for receiving events from a `ServerFormController`.
protocol ServerFormDelegate: AnyObject {
    /// Called to inform the delegate that the controller has constructed and committed the given server.
    /// - Parameter serverForm: The controller publishing this event.
    /// - Parameter server: The committed server.
    func serverForm(_ serverForm: ServerFormController, didCommitServer server: Server)
}
