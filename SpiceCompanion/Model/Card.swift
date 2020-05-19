//
//  Card.swift
//  Spice
//
//  Created by Gianni on 09/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

struct Card : Equatable, Codable {
    var name: String
    var cardNumber: String
    
    init(name: String, number: String){
        self.name = name
        self.cardNumber = number
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.name == rhs.name && lhs.cardNumber == rhs.cardNumber
    }
    
}
