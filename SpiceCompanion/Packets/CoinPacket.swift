//
//  CoinPacket.swift
//  Spice
//
//  Created by Gianni on 09/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class CoinPacket : DataPacket {
    
    init() {
        super.init(module: "coin", function: "insert")
//        super.addParam(param: "2")
    }
    
}
