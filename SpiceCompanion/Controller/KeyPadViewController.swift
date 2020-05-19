//
//  KeyPadViewController.swift
//  Spice
//
//  Created by Gianni on 15/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import UIKit
import CoreNFC

class KeyPadViewController: UIViewController, NFCTagReaderSessionDelegate {
    
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var doubleOButton: UIButton!
    @IBOutlet weak var dotButton: UIButton!
    
    @IBOutlet weak var pButton: UIButton!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var coinButton: UIButton!
    
    var playerOneSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        if(!NFCTagReaderSession.readingAvailable) {
            scanButton.isEnabled = false
            scanButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SelectedCard.card != nil {
            insertButton.isEnabled = true
            insertButton.tintColor = .red
        } else {
            insertButton.isEnabled = false
            insertButton.tintColor = .darkGray
        }
    }
    
    private func setupButtons(){
        
        let buttons:[UIButton] = [oneButton,twoButton,threeButton,fourButton,fiveButton,sixButton,sevenButton,eightButton,nineButton,zeroButton,doubleOButton,dotButton]
        let cellWidth:CGFloat = 70
        for button in buttons{
            setupButton(button: button, size: cellWidth)
        }
    }
    
    func getPlayerIndex() -> Int {
        return self.playerOneSelected ? 0 : 1
    }
    
    private func setupButton(button: UIButton, size: CGFloat){
        button.bounds.size = CGSize(width: size, height: size)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = size/2;
    }
    
    @IBAction func cardInsertPressed(_ sender: Any) {
        guard let card = SelectedCard.card else {
            return
        }

        let playerIndex = getPlayerIndex()
        let cardPacket = CardPacket(index: playerIndex, cardID: card.cardNumber)
        ConnectionController.get().sendPacket(packet: cardPacket)
    }
    
    @IBAction func coinButtonPressed(_ sender: Any) {
        let packet = CoinPacket()
        ConnectionController.get().sendPacket(packet: packet)
    }
    
    @IBAction func numberButtonPressed(_ sender: UIButton) {
        guard let keyCode = sender.titleLabel?.text else {
            return
        }
        sendKeyPad(keyCode: keyCode)
    }
    
    @IBAction func doubleOPressed(_ sender: Any) {
        sendKeyPad(keyCode: "A")
    }
    
    @IBAction func decimalPressed(_ sender: Any) {
        sendKeyPad(keyCode: "D")
    }
    
    func sendKeyPad(keyCode: String){
        let playerIndex = getPlayerIndex()
        let packet = KeyPadPacket(index: playerIndex, input: keyCode)
        ConnectionController.get().sendPacket(packet: packet)
    }
    
    
    @IBAction func playerButtonPressed(_ sender: UIButton) {
        playerOneSelected = !playerOneSelected
        
        if(playerOneSelected){
            sender.setTitle("P1", for: .normal)
        } else {
            sender.setTitle("P2", for: .normal)
        }
    }
    
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        nfcSession = NFCTagReaderSession.init(pollingOption: .iso18092, delegate: self)
        nfcSession?.begin()
    }
    
    private var nfcSession: NFCTagReaderSession?
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
            //Start Scanning
        }
        
        func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
            //Session closed
        }
        
        func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
            
            if tags.count > 1 {
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }
            
            let tag = tags.first!
            
            session.connect(to: tag) { (error) in
                if nil != error {
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    return
                }
                guard case .feliCa(let feliCaTag) = tag else {
                    let retryInterval = DispatchTimeInterval.milliseconds(500)
                    session.alertMessage = "A tag that is not FeliCa is detected, please try again with tag FeliCa."
                    DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                        session.restartPolling()
                    })
                    return
                }
                
                let idm = feliCaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined()
    //            let systemCode = feliCaTag.currentSystemCode.map { String(format: "%.2hhx", $0) }.joined()
                
                let playerIndex = self.getPlayerIndex()
                let cardPacket = CardPacket(index: playerIndex, cardID: idm)
                ConnectionController.get().sendPacket(packet: cardPacket)
                
                session.alertMessage = "Card Inserted."
                session.invalidate()
            }
        }

}
