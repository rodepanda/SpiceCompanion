//
//  LegacyStore.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import Foundation

/// The shared store of legacy settings that persists across application lifetimes via local storage.
///
/// Note that each instance of this store connects to the same backing file, so state must be synced
/// accordingly.
class LegacyStore: Store<LegacySettings> {

    init() {
        super.init(filename: "Settings", defaultContents: LegacySettings())
    }
}
