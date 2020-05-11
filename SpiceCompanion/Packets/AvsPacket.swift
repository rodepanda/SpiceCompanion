//
//  InfoPacket.swift
//  Spice
//
//  Created by Gianni on 14/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import Foundation

class AvsPacket: DataPacket {
    
    init(){
        super.init(module: "info", function: "avs")
    }
    
}
