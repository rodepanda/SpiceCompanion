//
//  CardTableViewController.swift
//  Spice
//
//  Created by Gianni on 08/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit

struct SelectedCard {
    static var card: Card?
}

class CardTableViewController: UITableViewController {

    var selectedCardRow: Int = -1

    private var cards: [Card] {
        get {
            return SettingsStore.shared.settings.cards
        }
        set {
            SettingsStore.shared.settings.cards = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        if(selectedCardRow > -1) {
            SelectedCard.card = cards[selectedCardRow]
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editCard"){
            let indexPath = tableView.indexPathForSelectedRow!
            let card = cards[indexPath.row]
            let navController = segue.destination as! UINavigationController
            let editCardViewController = navController.topViewController as! AddCardTableViewController
            editCardViewController.card = card
        }
    }
    
    func persistData(){
        try? SettingsStore.shared.save()
        persistCardRow()
    }
    
    func persistCardRow(){
        let defaults = UserDefaults.standard
        defaults.set(selectedCardRow, forKey: "selectedCardRow")
    }
    
    func loadData(){
        let defaults = UserDefaults.standard
        
        guard let selectedCardRow = defaults.object(forKey: "selectedCardRow") as? Int else {
            return
        }
        self.selectedCardRow = selectedCardRow
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }

    @IBAction
    func unwindToCardTableView(segue: UIStoryboardSegue){
        guard segue.identifier == "saveUnwind",
            let cardViewController = segue.source as? AddCardTableViewController,
            let card = cardViewController.card else { return }
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
           cards[selectedIndexPath.row] = card
            if(selectedIndexPath.row == selectedCardRow){
                SelectedCard.card = card
            }
           tableView.reloadRows(at: [selectedIndexPath], with: .none)
            let cell = tableView.cellForRow(at: IndexPath(row: selectedCardRow, section: 0))
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
       } else {
           let newIndexPath = IndexPath(row: cards.count, section: 0)
           cards.append(card)
           tableView.insertRows(at: [newIndexPath], with: .automatic)
       }
        persistData()
        return
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
        
        let card = cards[indexPath.row]
        cell.textLabel?.text = card.name
        cell.detailTextLabel?.text = card.id.uppercased()
        
        cell.accessoryType = (indexPath.row == selectedCardRow) ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.isEditing){
            performSegue(withIdentifier: "editCard", sender: self)
        } else {
            if selectedCardRow >= 0 {
                SelectedCard.card = cards[indexPath.row]
                let cell = tableView.cellForRow(at: IndexPath(row: selectedCardRow, section: 0))
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            }
            selectedCardRow = indexPath.row
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            SelectedCard.card = cards[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            persistCardRow()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            cards.remove(at: indexPath.row)
            if(selectedCardRow == indexPath.row){
                SelectedCard.card = nil
                selectedCardRow = -1
            }
            persistData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    // Allow rearreanging table.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedCard = cards.remove(at: fromIndexPath.row)
        cards.insert(movedCard, at: to.row)
        tableView.reloadData()
        guard let selectedCard = SelectedCard.card else {
            return
        }
        let newIndex = cards.firstIndex(of: selectedCard)
        let cell = tableView.cellForRow(at: IndexPath(row: newIndex!, section: 0))
        selectedCardRow = newIndex!
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        persistData()
    }

}
