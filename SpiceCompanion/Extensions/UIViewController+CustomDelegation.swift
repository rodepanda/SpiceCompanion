//
//  UIViewControllerExtension.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    @objc func showConnectionDialogOverlay(title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func connectingFailed() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func connectingSuccess() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func reconnect(){
        showConnectionDialogOverlay(title: "Reconnecting...")
    }
    
}
