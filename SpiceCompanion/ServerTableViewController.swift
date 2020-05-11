//
//  ServerTableViewController.swift
//  Spice
//
//  Created by Gianni on 13/12/2019.
//  Copyright © 2019 Rodepanda. All rights reserved.
//

import UIKit

struct Server: Codable {
    var name: String
    var host: String
    var port: UInt16
    var password: String?
}

class ServerTableViewController: UITableViewController {

    var servers: [Server] = [Server]()
    
    var client: ConnectionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    func persistData(){
        let propertyListEncoder = PropertyListEncoder()
        if let encodedServers = try? propertyListEncoder.encode(servers) {
            savePlist(fileName: "servers", data: encodedServers)
        }
    }
    
    func loadData(){
        guard let serverData = getPlist(fileName: "servers") else {
            return
        }
        let propertyListDecoder = PropertyListDecoder()
        if let decodedData = try? propertyListDecoder.decode([Server].self, from: serverData) {
            servers = decodedData
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editServer"){
            let indexPath = tableView.indexPathForSelectedRow!
            let server = servers[indexPath.row]
            let navController = segue.destination as! UINavigationController
            let editServerViewController = navController.topViewController as! EditServerViewController
            editServerViewController.server = server
        } else if (segue.identifier == "connectToServer") {
            let dest = segue.destination as UIViewController
            self.client!.setUIViewController(uiViewController: dest)
        }
    }
    
    @IBAction
    func unwindToServerTableView(segue: UIStoryboardSegue){
        if segue.identifier == "saveUnwind",
            let sourceViewController = segue.source as? EditServerViewController,
            let server = sourceViewController.server {
        
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                servers[selectedIndexPath.row] = server
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: servers.count, section: 0)
                servers.append(server)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            persistData()
            
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return servers.count
        return servers.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.isEditing){
            self.performSegue(withIdentifier: "editServer", sender: self)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            showConnectionDialogOverlay(title: "Connecting...")
            let server = servers[indexPath.row]
            client = ConnectionController(uiViewController: self, host: server.host, port: server.port, password: server.password)
            self.client!.connect()
        }
    }
    
    override func connectingSuccess() {
        dismiss(animated: true, completion: performSegueToTabbar)
    }
    
    func performSegueToTabbar(){
        performSegue(withIdentifier: "connectToServer", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serverCell", for: indexPath)
        let server = servers[indexPath.row]
        cell.textLabel?.text = server.name
        cell.detailTextLabel?.text = server.host + ":" + String(server.port)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            persistData()
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedServer = servers.remove(at: fromIndexPath.row)
        servers.insert(movedServer, at: to.row)
        tableView.reloadData()
        persistData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func connectingFailed() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: self.showNoConnectionError)
        }
    }
    
    private func showNoConnectionError(){
        let alert = UIAlertController(title: "Error", message: "Could not connect to server", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}
