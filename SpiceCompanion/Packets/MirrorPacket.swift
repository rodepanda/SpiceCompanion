//
//  MirrorPacket.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class MirrorPacket : DataPacket {
    init(){
        super.init(module: "capture", function: "get_jpg")
        addParam(param: "1")
        addParam(param: "40")
        addParam(param: "1")
    }
}
