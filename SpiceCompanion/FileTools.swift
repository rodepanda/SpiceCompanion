//
//  FileTools.swift
//  Spice
//
//  Created by Gianni on 09/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation

func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

func savePlist(fileName: String, data: Data) {
    let archiveUrl = getDocumentsDirectory().appendingPathComponent(fileName).appendingPathExtension("plist")
    try? data.write(to: archiveUrl, options: .noFileProtection)
}

func getPlist(fileName: String) -> Data? {
    let archiveUrl = getDocumentsDirectory().appendingPathComponent(fileName).appendingPathExtension("plist")
    return try? Data.init(contentsOf: archiveUrl)
}
