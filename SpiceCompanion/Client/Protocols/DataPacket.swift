//
//  SendingPacket.swift
//  Spice
//
//  Created by Gianni on 14/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import Foundation


class DataPacket {
    private var id: Int
    private var module: String
    private var function: String
    private var params: String
    private var firstParam = true

    private static var idCounter = 0;
    
    init(module: String, function: String){
        id = DataPacket.idCounter
        DataPacket.idCounter += 1
        self.module = module
        self.function = function
        params = ""
    }
    
    func addParam(param: String){
        if(!firstParam){
            params.append(", ")
        } else {
            firstParam = false;
        }
        params.append(param)
    }
    
    func encode() -> [UInt8] {
        let data = """
        {
        "id": \(id),
        "module": "\(module)",
        "function": "\(function)",
        "params": [\(params)]
        }
        \0
        """
        return Array(data.utf8);
    }
    
}

