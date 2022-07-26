//
//  PacketHandler.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol PacketHandler {
    func handlePacket(data: Array<JSON>)
}
