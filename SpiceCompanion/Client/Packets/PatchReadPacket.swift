//
//  PatchReadPacket.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class PatchReadPacket : DataPacket {
    init(binaryPatch: BinaryPatch) {
        super.init(module: "memory", function: "read")
        addParam(param: "\"\(binaryPatch.dllName)\"")
        addParam(param: String(binaryPatch.offset))
        
        //Divide by two because Spice expects an unsigned integer and I'm too tired to figure out how to easily convert a string to that notation
        //Offset should not be divided by two.
        addParam(param: String(binaryPatch.dataEnabled.count/2))
    }
}
