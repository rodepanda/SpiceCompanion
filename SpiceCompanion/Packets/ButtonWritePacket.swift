//
//  ButtonWritePacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 13/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class ButtonWritePacket : DataPacket {
    init(button: String, enable: Bool) {
        super.init(module: "buttons", function: "write")
        addParam(param: "[\"\(button)\", \(enable ? "1.0" : "0.0")]")
    }
}
