//
//  CardPacket.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class CardPacket: DataPacket {
    
    init(index: Int, cardID: String){
        super.init(module: "card", function: "insert")
        addParam(param: "\(index)")
        addParam(param: "\"\(cardID)\"")
    }
}
