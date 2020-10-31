//
//  MirrorConnectionController.swift
//  SpiceCompanion
//
//  Created by Gianni Hoffstedde on 27/10/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MirrorConnectionController: ConnectionControllerProtocol {
    
    private var uiViewController: UIViewController
    
    private let host: String
    private let port: UInt16
    private let password: String?
    private var spiceClient: SpiceClient?
    private var phase: ProtocolPhase
    
    
    private static var instance: MirrorConnectionController?
    
    static func get() -> MirrorConnectionController {
        return MirrorConnectionController.instance!
    }
    
    init(uiViewController: UIViewController, host: String, port: UInt16, password: String?){
        self.uiViewController = uiViewController
        self.host = host
        self.port = port
        self.password = password
        self.phase = .unknown
        MirrorConnectionController.instance = self
    }
    
    convenience init(uiViewController: UIViewController, host: String, port: UInt16){
        self.init(uiViewController: uiViewController, host: host, port: port, password: nil)
    }
    
    func setUIViewController(uiViewController: UIViewController){
        self.uiViewController = uiViewController
    }
    
    func getPassword() -> String? {
        return self.password
    }
    
    func usesPassword() -> Bool {
        return self.password != nil
    }
    
    func connect(){
        self.spiceClient = SpiceClient(host: host, port: port, controller: self)
        startTimer()
        self.spiceClient!.connect()
    }
    
    func connectedWithSuccess(){
        stopTimer()
        self.phase = .open
        let mvc = self.uiViewController as! MirrorViewController
        mvc.projectToMirror()
    }
    
    private var packetQueue: [DataPacket] = [DataPacket]()
    private var canSendPacket = true
    
    func sendPacket(packet: DataPacket){
        packetQueue.append(packet)
        processPacketQueue()
    }
    
    func processPacketQueue() {
        guard self.packetQueue.count > 0 else {
            return
        }
        if(self.canSendPacket) {
            self.spiceClient?.sendPacket(packet: packetQueue.removeFirst())
            self.canSendPacket = false
            startTimer()
        }
    }
    
    private var timer: Timer?
    private func startTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.timeOut), userInfo: nil, repeats: false)
        }
    }
    
    private func stopTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
        }
    }
    
    @objc func timeOut(){
        connectionBroken()
    }
    
    //Client dropped connection
    func connectionDroppedByClient(){
        DispatchQueue.main.async {
            self.uiViewController.reconnect()
        }
        self.spiceClient?.disconnect()
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
            self.uiViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    //Used to cancel connection in the event of protocol error, timeout or connection error.
    func connectionBroken(){
        spiceClient?.disconnect()
        self.uiViewController.connectingFailed()
    }
    
    func disconnect(){
        spiceClient?.disconnect()
    }
    
    var packetRes = ""
    
    func packetReceived(message: String){
        
        packetRes.append(message)
        
        let json = JSON(parseJSON: packetRes)
        
        if let errors = json["errors"].array {
            for error in errors {
                stopTimer()
                print(error)
                connectionBroken()
            }
        }
        
        guard let data = json["data"].array else {
            return
        }
        packetRes = String()
        
        processPacketQueue()
//        print(data)
        
        stopTimer()
        self.canSendPacket = true
        
        switch self.phase {
        case .open:
            guard let handler = self.packetHandler else {
                break
            }
            handler.handlePacket(data: data)
            break
        default:
            break
        }
    }
    
    private var packetHandler: PacketHandler?
    
    func setPacketHandler(packetHandler: PacketHandler){
        self.packetHandler = packetHandler;
    }
    
    func resetPacketHandler(){
        self.packetHandler = nil
    }
    
    func unsetDataHandler(){
        self.packetHandler = nil
    }
    
    private func handshakeFinished() {
        DispatchQueue.main.async {
            self.uiViewController.connectingSuccess()
        }
    }
    
}
