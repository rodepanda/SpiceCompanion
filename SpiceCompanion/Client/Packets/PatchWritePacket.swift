//
//  PatchWritePacket.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

class PatchWritePacket: DataPacket {

    init(patch: BinaryPatch, enable: Bool){
        super.init(module: "memory", function: "write")
        
        let patchData = enable ? patch.dataEnabled : patch.dataDisabled
        
        addParam(param: "\"\(patch.dllName)\"")
        addParam(param: "\"\(patchData)\"")
        addParam(param: "\(patch.offset)")
        
    }
}
