//
//  ButtonPacket.swift
//  SpiceCompanion
//
//  Created by Danny Lin on 5/30/20.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class ButtonPacket:DataPacket{
    init(){
        super.init(module: "buttons", function: "read")
    }
}
