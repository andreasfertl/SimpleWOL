//
//  Settings.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 03.04.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

protocol ConfigurationProtocol {
    func getConfiguration() -> [Element]?
    func saveConfig(element: Element?, index: Int, countOf: Int)
}

class Configuration : ConfigurationProtocol {

    let userSettings = UserDefaults.standard
    var numberOfElements = 0
    let numberOfElementsKeyword = "numberOfElements"

    func saveConfig(element: Element?, index: Int, countOf: Int) {
        if let element = element {
            //converting our element to a string representation to be able to store it
            let array = [String(element.id), element.name, element.macAddr]
            let idxString = String(index)
            userSettings.set(array, forKey: idxString)
            
            //keep our number of elements up to data, culd have been changed
            userSettings.set(countOf, forKey: numberOfElementsKeyword)
        }
    }
    
    func retriveUserSetting(idx: Int) -> Element? {
        let keyString = String(idx)

        let savedArray = userSettings.object(forKey: keyString) as? [String]
        if let savedArray = savedArray {
            if savedArray.count == 3 {
                let id :Int? = Int(savedArray[0])
                let name = savedArray[1]
                let macAddr = savedArray[2]
                if let id = id {
                    return Element(id: id, name: name, macAddr: macAddr)
                } else {
                    return nil

                }
            }
        }
        return nil
    }
    
    func getConfiguration() -> [Element]? {
        var configuration : [Element] = []
        
        let numberOfElements = userSettings.integer(forKey: numberOfElementsKeyword)
        if numberOfElements == 0 { //special case - no configuration stored
            return nil
        }
        
        var idx = 0
        while idx < numberOfElements {
            if let element = retriveUserSetting(idx: idx) {
                configuration.append(element)
            }
            idx += 1
        }
        
        if configuration.count > 0 {
            return configuration
        } else {
            return nil
        }
    }
}
