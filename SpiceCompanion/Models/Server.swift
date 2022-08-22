//
//  Server.swift
//  SpiceCompanion
//
//  Created by marika on 2022-08-22.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import Foundation

/// A single configured Spice server that can be connected to.
struct Server: Codable {

    /// The human-readable display name of this server.
    var name: String

    /// The address of the host of this server.
    var host: String

    /// The port on the host that the TCP API is hosted on.
    var port: UInt16

    /// The password to use to encrypt data transferred to and from this server.
    var password: String?
}
