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
            ConnectionController.get().disconnect()
            performSegue(withIdentifier: "userDisconnect", sender: self)
        }
    }
    
}
