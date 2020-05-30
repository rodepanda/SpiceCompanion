//
//  UIDevice+GetDeviceType.swift
//  SpiceCompanion
//
//  Created by Danny Lin on 5/26/20.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation
import UIKit

public enum DeviceType:Equatable {
 case iPad(String?)
 case iPhone(String?)
 case simulator(String?)
 case appleTV(String?)
 case unknown
}

extension UIDevice {
    public static func getDevice() -> DeviceType {
        var info = utsname()
        uname(&info)
        let machineMirror = Mirror(reflecting: info.machine)
        let code = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        if code.lowercased().range(of: "ipad") != nil {
            if let range = code.lowercased().range(of: "ipad") {
                var mutate = code
                mutate.removeSubrange(range)
                return .iPad(mutate)
            }else{
                return .iPad(nil)
            }
        }else if code.lowercased().range(of: "iphone") != nil {
            if let range = code.lowercased().range(of: "iphone") {
                var mutate = code
                mutate.removeSubrange(range)
                return .iPhone(mutate)
            }else{
                return .iPhone(nil)
            }
        }else if code.lowercased().range(of: "i386") != nil || code.lowercased().range(of: "x86_64") != nil{
            return .simulator(code)
        }else if code.lowercased().range(of: "appletv") != nil {
            if let range = code.lowercased().range(of: "appletv") {
                var mutate = code
                mutate.removeSubrange(range)
                return .appleTV(mutate)
            }else{
                return .appleTV(nil)
            }
        }else{
            return .unknown
        }
    }
}
