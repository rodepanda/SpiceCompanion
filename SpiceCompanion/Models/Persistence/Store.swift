//
//  Store.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import Foundation

/// A single store of data that persists across application lifetimes via local storage.
class Store<Contents: Codable>: ObservableObject {

    /// The name of this store's backing file in local storage, without a path extension.
    private let filename: String

    /// The default contents of this store to use when there are no contents present.
    private let defaultContents: Contents

    init(filename: String, defaultContents: Contents) {
        self.filename = filename
        self.defaultContents = defaultContents
    }

    /// Load the contents of this store from local storage.
    /// - Returns: The contents of this store, or the default contents if there are none.
    func load() async throws -> Contents {
        return try await Task.detached(priority: .background) {
            let fileUrl = try self.getFileUrl()
            guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                return self.defaultContents
            }

            let decoder = PropertyListDecoder()
            return try decoder.decode(Contents.self, from: file.availableData)
        }.value
    }

    /// Save the given contents of this store to local storage.
    /// - Parameter contents: The contents to save.
    func save(contents: Contents) async throws {
        try await Task.detached(priority: .background) {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(contents)
            try data.write(to: try self.getFileUrl())
        }.value
    }

    /// Get the URL of the file containing this store's persisted data.
    /// - Returns: The URL of this store's backing file.
    private func getFileUrl() throws -> URL {
        let documentsUrl = try FileManager.default.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)

        return documentsUrl.appendingPathComponent("\(filename).plist")
    }
}
