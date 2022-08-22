//
//  Settings.swift
//  SpiceCompanion
//
//  Created by marika on 2022-08-22.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

/// Options and values set by the user.
struct Settings: Codable {

    /// The servers that the user has added.
    var servers = [Server]()

    /// The cards that the user has added.
    var cards = [Card]()
}
