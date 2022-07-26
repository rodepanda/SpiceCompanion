//
//  QuitApplicationPacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 13/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class QuitApplicationPacket : DataPacket {
    init() {
        super.init(module: "control", function: "exit")
    }
}
