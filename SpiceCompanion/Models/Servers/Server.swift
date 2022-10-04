//
//  Server.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import Foundation

/// A single defined Spice server that can be connected to.
struct Server: Identifiable, Codable {

    /// The unique internal identifier of this server.
    var id: UUID

    /// The human-readable display name of this server.
    var name: String

    /// The address of the host of this server.
    var host: String

    /// The port on the host that the TCP API is hosted on.
    var port: UInt16

    /// The password to use to encrypt data transferred to and from this server, if any.
    ///
    /// If this is `nil` then this server does not use encryption and communicates over plaintext.
    var password: String?

    init(id: UUID = UUID(), name: String, host: String, port: UInt16, password: String? = nil) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.password = password
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        host = try container.decode(String.self, forKey: .host)
        port = try container.decode(UInt16.self, forKey: .port)
        password = try? container.decode(String.self, forKey: .password)
    }
}
