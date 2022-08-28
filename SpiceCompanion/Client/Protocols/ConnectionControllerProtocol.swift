//
//  ConnectionControllerProtocol.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

protocol ConnectionControllerProtocol {
    func getPassword() -> String?
    func connectedWithSuccess()
    func connectionBroken()
    func connectionDroppedByClient()
    func packetReceived(message: String)
}
