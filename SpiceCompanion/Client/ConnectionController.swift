//
//  ConnectionController.swift
//  Spice
//
//  Created by Gianni on 15/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

//Contains a patch and if it's enabled
struct PatchState {
    let patch: Patch
    var enabled: Bool
    
    init(patch: Patch, enabled: Bool){
        self.patch = patch
        self.enabled = enabled
    }
}

struct ApplicationInfo {
    var model: String
    var dest: String
    var spec: String
    var rev: String
    var ext: Int
    var services: String
    var version: String
}

class ConnectionController : ConnectionControllerProtocol {
    
    private var uiViewController: UIViewController
    
    let server: Server
    private var spiceClient: SpiceClient?
    private var phase: ProtocolPhase
    
    var appInfo: ApplicationInfo?
    var screens: [Int] = []
    
    var patchStates: [PatchState]
    
    private static var instance: ConnectionController?
    
    static func get() -> ConnectionController {
        return ConnectionController.instance!
    }
    
    init(uiViewController: UIViewController, server: Server){
        self.uiViewController = uiViewController
        self.server = server
        self.phase = .unknown
        self.patchStates = [PatchState]()
        ConnectionController.instance = self
    }
    
    func setUIViewController(uiViewController: UIViewController){
        self.uiViewController = uiViewController
    }
    
    func getPassword() -> String? {
        return self.server.password
    }
    
    func usesPassword() -> Bool {
        return self.server.password != nil
    }
    
    func connect(){
        self.spiceClient = SpiceClient(host: server.host, port: server.port, controller: self)
        startTimer()
        self.spiceClient!.connect()
    }
    
    func connectedWithSuccess(){
        stopTimer()
        let info = AvsPacket()
        sendPacket(packet: info)
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
        self.spiceClient = SpiceClient(host: server.host, port: server.port, controller: self)
        self.phase = .unknown
        
        print("RECONNECTING")
        self.spiceClient?.connect()
        
        startTimer()
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
        
        stopTimer()
        self.canSendPacket = true
        
        processPacketQueue()
//        print(data)
        
        
        switch self.phase {
        case .unknown:
            parseApplicationInfo(data: data)
            break
        case .info:
            parseInfo(data: data)
            break
        case .screeninfo:
            scanScreens(data: data)
            break
        case .scanning:
            scannedPatch(data: data)
            break
        case.open:
            break
        }
    }
    
    private var patchScanQueue: [Patch]?
    
    private func parseApplicationInfo(data: [JSON]){
        guard let applicationData = data[0].dictionary, let model = applicationData["model"]?.string, let dateCode = applicationData["ext"]?.string else {
            connectionBroken()
            return
        }
        
        guard let dest = applicationData["dest"]?.string,
        let spec = applicationData["spec"]?.string,
        let rev = applicationData["rev"]?.string,
            let services = applicationData["services"]?.string else {
                connectionBroken()
                return
        }
        
        let dateCodeInt: Int = Int(dateCode)!
        
        self.appInfo = ApplicationInfo(model: model, dest: dest, spec: spec, rev: rev, ext: dateCodeInt, services: services, version: "")
        
        self.phase = .info
        let infoPacket = LauncherPacket()
        sendPacket(packet: infoPacket)
    }
    
    private func parseInfo(data: [JSON]){
        
        guard let applicationData = data[0].dictionary, let version = applicationData["version"]?.string else {
            connectionBroken()
            return
        }
        self.appInfo?.version = version
        self.phase = .screeninfo
        
        if(self.appInfo?.model == "000"){
            self.phase = .open
            handshakeFinished()
            return
        }
        
        let screenPacket = GetScreensPacket()
        sendPacket(packet: screenPacket)
        
    }
    
    private func scanScreens(data: [JSON]){
        
        self.screens.removeAll()
        self.phase = .scanning
        for screenId in data {
            self.screens.append(screenId.int!)
        }
        
        if(!usesPassword()) {
            self.phase = .open
            handshakeFinished()
            return
        }
        
        self.patchScanQueue = PatchManager.get().getPatches(model: self.appInfo!.model, dateCode: self.appInfo!.ext)
        self.patchStates = [PatchState]()
        scanPatch()
        
    }
    
    private func scanPatch(){
        
        guard let patch = self.patchScanQueue?.first else {
            self.phase = .open
            handshakeFinished()
            return
        }
        guard let binaryPatch = patch.patches.first else {
            self.patchScanQueue?.removeFirst()
            scanPatch()
            return
        }
        
        let patchPacket = PatchReadPacket(binaryPatch: binaryPatch)
        sendPacket(packet: patchPacket)
    }
    
    private func scannedPatch(data: [JSON]){
        guard let serverValue = data[0].string else {
            connectionBroken()
            return
        }
        let scannedPatch = self.patchScanQueue!.removeFirst()
        
        let enabled = scannedPatch.patches[0].dataEnabled == serverValue
        let patchState = PatchState(patch: scannedPatch, enabled: enabled)
        self.patchStates.append(patchState)
        scanPatch()
    }
    
    private func handshakeFinished() {
        DispatchQueue.main.async {
            self.uiViewController.connectingSuccess()
        }
    }
    
}

enum ProtocolPhase {
    //Unknown model and datecode
    case unknown
    
    //Obtaining Spice Information
    case info
    
    //Scanning patches
    case scanning
    
    //Scanning amount of screens
    case screeninfo
    
    //Ready to send packets
    case open
}
