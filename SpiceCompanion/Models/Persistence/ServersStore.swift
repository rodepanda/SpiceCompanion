//
//  ServersStore.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import Foundation

/// The shared store of servers that persists across application lifetimes via local storage.
///
/// Note that each instance of this store connects to the same backing file, so state must be synced
/// accordingly.
class ServersStore: Store<[Server]> {

    init() {
        super.init(filename: "servers", defaultContents: {
            // check for legacy servers
            let legacyStore = LegacyStore()
            return (try? await legacyStore.load().servers) ?? []
        })
    }
}
