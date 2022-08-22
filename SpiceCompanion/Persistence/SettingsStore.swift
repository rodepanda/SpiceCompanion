//
//  SettingsStore.swift
//  SpiceCompanion
//
//  Created by marika on 2022-08-22.
//  Copyright © 2022 Rodepanda. All rights reserved.
//

import Foundation

/// An object for managing persistence of user settings in local storage.
///
/// Note that data is not automatically loaded on initialization, `SettingsStore.load()` must be
/// performed at least once.
class SettingsStore {

    /// The local file URL of the backing property list of this store.
    private let fileUrl = try! FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("Settings.plist")

    /// The settings currently within this store.
    var settings = Settings()

    /// Load the contents of this store from local storage into this instance.
    func load() throws {
        // handle legacy stores to maintain data between versions
        if let cards: [Card] = try readLegacyStore(filename: "cards.plist") {
            settings.cards = cards
        }

        if let servers: [Server] = try readLegacyStore(filename: "servers.plist") {
            settings.servers = servers
        }

        // load the data from local storage
        guard let handle = try? FileHandle(forReadingFrom: fileUrl) else {
            return
        }

        let decoder = PropertyListDecoder()
        settings = try decoder.decode(Settings.self, from: handle.availableData)
    }

    /// Write the contents of this store instance to local storage.
    func save() throws {
        // write the data to local storage
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(settings)
        try data.write(to: fileUrl)
    }

    /// Attempt to read the contents of a legacy store from local storage.
    /// - Parameter filename: The name of the file within the documents directory containing the
    /// legacy store.
    /// - Returns: The contents of the legacy store, if any.
    private func readLegacyStore<T: Codable>(filename: String) throws -> [T]? {
        let url = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)

        guard let handle = try? FileHandle(forReadingFrom: url) else {
            // the file does not exist, so assume the legacy store does not exist
            return nil
        }

        let decoder = PropertyListDecoder()
        return try decoder.decode([T].self, from: handle.availableData)
    }
}
