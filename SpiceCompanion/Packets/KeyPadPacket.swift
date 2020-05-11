//
//  KeyPadPacket.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class KeyPadPacket: DataPacket {
    init(index: Int, input: String){
        super.init(module: "keypads", function: "write")
        addParam(param: "\(index)")
        addParam(param: "\"\(input)\"")
    }
}
