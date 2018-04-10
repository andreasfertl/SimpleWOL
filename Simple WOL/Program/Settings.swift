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
    func saveConfig(element: Element?, idx: Int)
    func deleteConfig(element: Element, idx: Int)
}

class Configuration : ConfigurationProtocol {

    let userSettings = UserDefaults.standard
    var configElements : [Element] = []
    let numberOfElementsKeyword = "numberOfElements"
    
    func storeAllElements()  {
        //store all elements
        for index in 0 ..< configElements.count {
            let showOnAppleWatch = configElements[index].showOnAppleWatch ? "true" : "false"
            let array = [configElements[index].name, configElements[index].macAddr, showOnAppleWatch]
            let idxString = String(index)
            
            userSettings.set(array, forKey: idxString)
        }

        //and we need to keep our number of elements up to data, could been changed
        userSettings.set(configElements.count, forKey: numberOfElementsKeyword)
    }

    func saveConfig(element: Element?, idx: Int) {
        if let element = element {
            //update our internal copy
            if idx >= configElements.count {
                configElements.insert(element, at: idx)
            } else {
                configElements[idx] = element
            }
            
            //and update storage
            storeAllElements()
        }
    }
    
    func deleteConfig(element: Element, idx: Int){
        //find the one we are looking for
        if idx < configElements.count {
            configElements.remove(at: idx)
            //and update storage
            storeAllElements()
        }
    }
    
    func retriveUserSetting(idx: Int) -> Element? {
        let keyString = String(idx)

        let savedArray = userSettings.object(forKey: keyString) as? [String]
        if let savedArray = savedArray {
            if savedArray.count == 3 {
                let name = savedArray[0]
                let macAddr = savedArray[1]
                let showOnAppleWatch = savedArray[2]
                if showOnAppleWatch == "true" {
                    return Element(name: name, macAddr: macAddr, showOnAppleWatch: true)
                } else {
                    return Element(name: name, macAddr: macAddr, showOnAppleWatch: false)
                }
                
            }
        }
        return nil
    }
    
    func getConfiguration() -> [Element]? {
        
        let numberOfElements = userSettings.integer(forKey: numberOfElementsKeyword)
        if numberOfElements == 0 { //special case - no configuration stored
            return nil
        }
        
        for idx in 0..<numberOfElements {
            if let element = retriveUserSetting(idx: idx) {
                configElements.append(element)
            }
        }
        
        if configElements.count > 0 {
            return configElements
        } else {
            return nil
        }
    }
}
