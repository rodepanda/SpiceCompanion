//
//  EditServerViewController.swift
//  Spice
//
//  Created by Gianni on 13/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import UIKit



class EditServerViewController: UITableViewController {

    var server: Server?
    
    var editFlag:Bool = false
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var hostNameField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var delegate: EditServerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        hostNameField.delegate = self
        portField.delegate = self
        passwordField.delegate = self
        
        if let server = server {
            nameField.text = server.name
            hostNameField.text = server.host
            portField.text = String(server.port)
            passwordField.text = server.password
            self.title = "Edit server"
            editFlag = true
        }
        
        updateSaveButtonState()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField){
        updateSaveButtonState()
    }
    
    func updateSaveButtonState(){
        
        let name = nameField.text ?? ""
        let hostName = hostNameField.text ?? ""
        let port = Int(portField.text!) ?? 0
        
        saveButton.isEnabled = !name.isEmpty && !hostName.isEmpty && port > 0 && port < 65536
    }
    
    @IBAction func saveServer(_ sender: Any) {
        let name = nameField.text ?? ""
        let hostName = hostNameField.text ?? ""
        let port = UInt16(portField.text!) ?? 1
        let password = passwordField.text
        server = Server(name: name, host: hostName, port: port, password: password!.isEmpty ? nil : password)
        if editFlag{
            self.delegate?.saveEditedServer(server: server!)
            self.dismiss(animated: true, completion: nil)
        }else{
            self.delegate?.saveNewServer(server: server!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        guard segue.identifier == "saveUnwind" else { return }
//
//        let name = nameField.text ?? ""
//        let hostName = hostNameField.text ?? ""
//        let port = UInt16(portField.text!) ?? 1
//        let password = passwordField.text
//        server = Server(name: name, host: hostName, port: port, password: password!.isEmpty ? nil : password)

//    }
    
    

}

extension EditServerViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            hostNameField.becomeFirstResponder()
        case hostNameField:
            portField.becomeFirstResponder()
        case portField:
            passwordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}


protocol EditServerViewControllerDelegate {
    func saveEditedServer(server: Server)
    func saveNewServer(server: Server)
}
