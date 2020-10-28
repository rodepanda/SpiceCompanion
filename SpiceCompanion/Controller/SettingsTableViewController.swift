//
//  SettingsTableViewController.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBOutlet weak var applicationLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appInfo = ConnectionController.get().appInfo else {
            return
        }
        let application = "\(appInfo.model):\(appInfo.dest):\(appInfo.spec):\(appInfo.rev):\(appInfo.ext)"
        applicationLabel.text = application
        versionLabel.text = "Spice Version: \(appInfo.version)"
        serviceLabel.text = "Services: \(appInfo.services)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.section == 2){
            
            switch indexPath.row{
            case 0:
                mirrorButtonPressed()
                break;
            case 1:
                self.applicationButtonPressed(button: "Test")
                break
            case 2:
                self.applicationButtonPressed(button: "Service")
                break
            case 3:
                self.quitButtonPressed()
            default:
                break
            }
            return
        }
        
        if(indexPath.section == 3){
            ConnectionController.get().disconnect()
            //performSegue(withIdentifier: "userDisconnect", sender: self)
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    func mirrorButtonPressed(){
        let mirror = self.storyboard?.instantiateViewController(withIdentifier: "MirrorViewController") as! UIViewController
        present(mirror, animated: true, completion: nil)
    }
    
    func applicationButtonPressed(button: String){
        let packet = ButtonWritePacket(button: button, enable: true)
        ConnectionController.get().sendPacket(packet: packet)
        //Make sure the game had at least a frame to detect the keystate.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        ConnectionController.get().sendPacket(packet: ButtonResetPacket(button: button))
        }
    }
    
    func quitButtonPressed(){
        ConnectionController.get().sendPacket(packet: QuitApplicationPacket())
    }
    
}
