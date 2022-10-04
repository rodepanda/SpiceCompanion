//
//  LegacySettings.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import Foundation

/// Options and values set by the user in `1.4.0` via the legacy `Settings` data structure.
struct LegacySettings: Codable {

    /// The servers that the user has added.
    var servers = [Server]()

    /// The cards that the user has added.
    var cards = [Card]()
}
