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
            
            self.dismiss(animated: true, completion: self.showNoConnectionError)
        }
    }
    
    func showNoConnectionError() {
        let alert = UIAlertController(title: "Disconnected from server", message: "Connection lost", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
        
    }
    
    

}
