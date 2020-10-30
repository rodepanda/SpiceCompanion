//
//  UIView+TakeSnapshot.swift
//  SpiceCompanion
//
//  Created by Danny Lin on 10/30/20.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func takeSnapshot() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
