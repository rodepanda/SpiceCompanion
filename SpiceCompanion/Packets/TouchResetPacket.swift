//
//  TouchResetPacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class TouchResetPacket : DataPacket {

    init(id: Int){
        super.init(module: "touch", function: "write_reset")
        addParam(param: "\(id)")
    }
}
