//
//  PatchTableViewController.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit

class PatchTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!ConnectionController.get().usesPassword() || ConnectionController.get().appInfo?.model == "000") {
            return
        }
        
        ConnectionController.get().patchStates[indexPath.row].enabled = !ConnectionController.get().patchStates[indexPath.row].enabled
        
        let patchState = ConnectionController.get().patchStates[indexPath.row]
        let binaryPatches = patchState.patch.patches
        
        for patch in binaryPatches {
            let packet = PatchWritePacket(patch: patch, enable: patchState.enabled)
            ConnectionController.get().sendPacket(packet: packet)
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = patchState.enabled ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(!ConnectionController.get().usesPassword() || ConnectionController.get().appInfo?.model == "000") {
            return 1
        }
        
        return ConnectionController.get().patchStates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patchCell", for: indexPath)

        if(!ConnectionController.get().usesPassword()){
            cell.textLabel?.text = "Patching Module Disabled!"
            cell.detailTextLabel?.text = "No Password Set."
            cell.selectionStyle = .none
            return cell
        }
        
        if(ConnectionController.get().appInfo?.model == "000"){
            cell.textLabel?.text = "Patching Module Disabled!"
            cell.detailTextLabel?.text = "No Patches Found."
            cell.selectionStyle = .none
            return cell
        }
        
        let patchState = ConnectionController.get().patchStates[indexPath.row]
        
        cell.textLabel?.text = patchState.patch.name
        cell.detailTextLabel?.text = patchState.patch.description
        
        cell.accessoryType = patchState.enabled ? .checkmark : .none
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var shouldAutorotate: Bool{
        return false
    }

}
