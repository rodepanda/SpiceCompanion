//
//  SpiceClient.swift
//  Spice
//
//  Created by Gianni on 14/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import Foundation
import Network
class SpiceClient {
    
    private var connection: NWConnection
    private let connectionController: ConnectionController
    private var rc4: Rc4?
    
    init(host: String, port: UInt16, controller: ConnectionController){
        self.connectionController = controller
        let connectionPort = NWEndpoint.Port(rawValue: port)
        connection = NWConnection(host: NWEndpoint.Host(host), port: connectionPort!, using: .tcp)
        connection.stateUpdateHandler = self.stateDidChange(to:)
    }
    
    func connect(){
        self.generateKey()
        connection.start(queue: DispatchQueue.global())
    }
    
    func generateKey(){
        guard let password = connectionController.getPassword() else {
            return
        }
        let passwordBytes = Array(password.utf8)
        self.rc4 = Rc4(password: passwordBytes)
    }
    
    private func stateDidChange(to state: NWConnection.State){
        switch state {
        case .ready:
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion: receive(data:context:complete:error:))
            connectionController.connectedWithSuccess()
            break
        case .waiting(_):
            connectionController.connectionBroken()
            break
        case.failed(let error):
            if(error == NWError.posix(POSIXErrorCode.ECONNABORTED)){
                self.connectionController.connectionDroppedByClient()
            } else {
                self.connectionController.connectionBroken()
            }
            break
        default:
            break
        }
        
    }
    
    func printPacket(_ string: String){
        print(string)
    }
    
    func sendPacket(packet: DataPacket) {
        var packet = packet.encode()
        printPacket(String(bytes: packet, encoding: .utf8)!)
        if let rc4 = self.rc4 {
            packet = rc4.encrypt(text: packet)
        }
        self.connection.send(content: packet, completion: .contentProcessed(contentProcessed(error:)))
    }
    
    func receive(data: Data?, context: NWConnection.ContentContext?, complete: Bool, error: NWError?){
        if(data == nil) {
            self.connection.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion: receive(data:context:complete:error:))
            return
        }
        var data = [UInt8](data!)
        
        //Encrypt also decrypts encrypted data.
        if let rc4 = self.rc4 {
            data = rc4.encrypt(text: data)
        }
        
        data.removeLast()
        guard let receivedMessage = String(bytes: data, encoding: .utf8) else {
            disconnect()
            self.connectionController.connectionBroken()
            return
        }
        
        printPacket(receivedMessage)
        //Open pipeline for new data
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion: receive(data:context:complete:error:))
        
        self.connectionController.packetReceived(message: receivedMessage)
    }
    
    //Called when packet is send.
    func contentProcessed(error: NWError?){
        guard let error = error else { return }
        print(error.debugDescription)
    }
    
    func disconnect(){
        self.connection.cancel()
    }
    
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
