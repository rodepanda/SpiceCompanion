//
//  PatchManager.swift
//  Spice
//
//  Created by Gianni on 10/05/2020.
//  Copyright © 2020 Rodepanda. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Patch {
    
    let name: String
    let description: String
    let type: String
    let preset: Bool
    let patches: [BinaryPatch]
    
    init(name: String, description: String, type: String, preset: Bool, patches: [BinaryPatch]) {
        self.name = name
        self.description = description
        self.type = type
        self.preset = preset
        self.patches = patches
    }
}

struct BinaryPatch {
    let dllName: String
    let dataDisabled: String
    let dataEnabled: String
    let offset: Int
    
    init(dllName: String, dataDisabled: String, dataEnabled: String, offset: Int) {
        self.dllName = dllName
        self.dataDisabled = dataDisabled
        self.dataEnabled = dataEnabled
        self.offset = offset
    }
}

class PatchManager {
    
    private static var instance: PatchManager?
    
    private var models: [String: AugmentedIntervalTree<Int>]
    
    static func get() -> PatchManager{
        if (PatchManager.instance == nil){
            PatchManager.instance = PatchManager()
        }
        return PatchManager.instance!
    }
    
    private init() {
        models = [:]
        loadPatches()
    }
    
    private func loadPatches() {
        let mainBundle = Bundle.main
        let path = mainBundle.path(forResource: "patches", ofType: "json")
        let fileContents = try! String(contentsOfFile: path!)
        let json = JSON(parseJSON: fileContents)
        parseAndInsertPatches(json: json)
    }
    
    private func parseAndInsertPatches(json: JSON){
        patch: for (_, subJson):(String, JSON) in json {
            
            let gameCode = subJson["gameCode"].stringValue
            if (self.models[gameCode] == nil){
                let newTree = AugmentedIntervalTree<Int>()
                self.models[gameCode] = newTree
            }
            
            var tree = self.models[gameCode]!
            
            var minDate: Int
            var maxDate: Int
            if(subJson["dateCode"].exists()){
                minDate = subJson["dateCode"].intValue
                maxDate = subJson["dateCode"].intValue
            } else {
                minDate = subJson["dateCodeMin"].intValue
                maxDate = subJson["dateCodeMax"].intValue
            }
            
            let dateCodeInterval = Interval(start: minDate, end: maxDate)
            let overlaps = tree.overlaps(with: dateCodeInterval)
            let patch = createPatch(json: subJson)
            
            for interval in overlaps {
                if(interval == dateCodeInterval){
                    interval.patches.append(patch)
                    
                    //Reassign because after unwrapping you don't have a reference to the original anymore.
                    self.models[gameCode] = tree
                    continue patch
                }
            }
            dateCodeInterval.patches.append(patch)
            tree.insert(dateCodeInterval)
            self.models[gameCode] = tree
            
        }
    }
    
    private func createPatch(json: JSON) -> Patch{
        var binaryPatches = [BinaryPatch]()
        for patchData in json["patches"].arrayValue {
            let binaryPatch = createBinaryPatch(patchData: patchData)
            binaryPatches.append(binaryPatch)
        }
        
        let name = json["name"].stringValue
        let description = json["description"].stringValue
        let type = json["type"].stringValue
        let preset = json["preset"].boolValue
        
        let patch = Patch(name: name, description: description, type: type, preset: preset, patches: binaryPatches)
        return patch
    }
    
    private func createBinaryPatch(patchData: JSON) -> BinaryPatch {
        let name = patchData["dllName"].stringValue
        let dataDisabled = patchData["dataDisabled"].stringValue
        let dataEnabled = patchData["dataEnabled"].stringValue
        let dataOffset = patchData["dataOffset"].intValue
        let binaryPatch = BinaryPatch(dllName: name, dataDisabled: dataDisabled, dataEnabled: dataEnabled, offset: dataOffset)
        return binaryPatch
    }
    
    func getPatches(model: String, dateCode: Int) -> [Patch]{
        guard let game = models[model] else {
            return Array()
        }
        
        let dateCodeInterval = Interval(start: dateCode, end: dateCode)
        let patchIntervals = game.overlaps(with: dateCodeInterval)
        var patches = [Patch]()
        for patchInterval in patchIntervals {
            for patch in patchInterval.patches {
                patches.append(patch)
            }
        }
        return patches
    }
    
}
