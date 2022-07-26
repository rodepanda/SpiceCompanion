//
//  TouchWritePacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class TouchWritePacket : DataPacket {

    init(id: Int, x: Int, y: Int){
        super.init(module: "touch", function: "write")
        addParam(param: "[\(id), \(x), \(y)]")
    }
}
