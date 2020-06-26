//
//  AddCardTableViewController.swift
//  Spice
//
//  Created by Gianni on 08/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit
import CoreNFC

class AddCardTableViewController: UITableViewController, NFCTagReaderSessionDelegate, UITextFieldDelegate {

    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var card: Card?
    
    var hasNFC: Bool?
    @IBOutlet weak var scanButton: UILabel!
    @IBOutlet weak var scanCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        numberField.delegate = self
        
        if let card = card {
            nameField.text = card.name
            numberField.text = card.cardNumber
            super.title = "Edit Card"
        }
        
        self.hasNFC = NFCTagReaderSession.readingAvailable
        
        if(!self.hasNFC!){
            scanButton.isEnabled = false
            scanCell.selectionStyle = .none
        }
        
        updateSaveButtonState()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case nameField:
                numberField.becomeFirstResponder()
            case numberField:
                textField.resignFirstResponder()
            default:
                textField.resignFirstResponder()
            }
        return false
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField){
        updateSaveButtonState()
    }
    
    func updateSaveButtonState(){
        
        let name = nameField.text ?? ""
        let cardNumber = numberField.text?.lowercased() ?? ""
        
        saveButton.isEnabled = !name.isEmpty && !cardNumber.isEmpty && cardNumber.count == 16 && cardNumber.range(of: "^[a-fA-F\\d]*$", options: .regularExpression, range: nil, locale: nil) != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "saveUnwind" else {
            return
        }
        
        let name = nameField.text ?? ""
        let cardNumber = numberField.text?.lowercased() ?? ""
        self.card = Card(name: name, number: cardNumber)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard indexPath.section == 2 && hasNFC! else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
                    
                    session.alertMessage = "Card Scanned"
                    session.invalidate()
                    DispatchQueue.main.async {
                        self.numberField.text! = idm
                        self.updateSaveButtonState()
                    }
                }
            }
    
}
