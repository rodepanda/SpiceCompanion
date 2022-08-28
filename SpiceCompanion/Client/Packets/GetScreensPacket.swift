//
//  GetScreensPacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 28/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class GetScreensPacket : DataPacket {
    init(){
        super.init(module: "capture", function: "get_screens")
    }
}
