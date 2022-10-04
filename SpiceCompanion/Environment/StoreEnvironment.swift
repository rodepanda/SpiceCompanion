//
//  StoreEnvironment.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import SwiftUI

// MARK: - Servers

private struct ServersStoreEnvironmentKey: EnvironmentKey {
    static let defaultValue = ServersStore()
}

extension EnvironmentValues {
    var serversStore: ServersStore {
        get { self[ServersStoreEnvironmentKey.self] }
        set { self[ServersStoreEnvironmentKey.self] = newValue }
    }
}
