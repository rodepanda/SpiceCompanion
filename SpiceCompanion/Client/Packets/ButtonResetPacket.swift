//
//  ButtonResetPacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 13/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class ButtonResetPacket : DataPacket {
    init(button: String) {
        super.init(module: "buttons", function: "write_reset")
        addParam(param: "[\"\(button)\"]")
    }
}
