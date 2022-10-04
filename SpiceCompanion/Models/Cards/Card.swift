//
//  Card.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-03.
//

import Foundation

/// A digital NFC card that can be used to login to Spice.
struct Card: Identifiable, Equatable, Codable {

    /// The unique internal identifier of this card.
    var id: UUID

    /// The human-readable display name of this card.
    var name: String

    /// The unique number of this card used by the server to identify it.
    ///
    /// This is typically formatted as `E004` followed by 12 hexadecimal characters, but several newer and
    /// older formats exist that can be used.
    var number: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)

        if container.contains(.number) {
            self.number = try container.decode(String.self, forKey: .number)
        }
        else {
            self.number = try container.decode(String.self, forKey: .legacyNumber)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
    }
}

// MARK: - Enumerations

extension Card {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case number

        case legacyNumber = "cardNumber" //backwards compatibility
    }
}
