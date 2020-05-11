//
//  SpicePacket.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class LauncherPacket: DataPacket {
    init(){
        super.init(module: "info", function: "launcher")
    }
}
