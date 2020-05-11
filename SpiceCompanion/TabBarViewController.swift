//
//  TabBarViewController.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func connectingFailed() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Disconnected from server", message: "Connection lost", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in self.unwindToServerSelect() }))
            self.present(alert, animated: true)
        }
    }
    
    private func unwindToServerSelect(){
        performSegue(withIdentifier: "serverDisconnect", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
