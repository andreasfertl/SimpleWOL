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
    func saveConfig(element: Element?)
}

class Configuration : ConfigurationProtocol {

    let userSettings = UserDefaults.standard
    var lastUsedId = 0
    let lastUsedIdKeyword = "lastUsedId"

    func saveConfig(element: Element?) {
        if let element = element {
            //converting our element to a string representation to be able to store it
            let keyString = String(element.id)
            let array = [element.name, element.macAddr]
            userSettings.set(array, forKey: keyString)
            
            //keep our last used id up to date
            if element.id > lastUsedId {
                userSettings.set(element.id, forKey: lastUsedIdKeyword)
            }
        }
    }
    
    func retriveUserSetting(id: Int) -> Element? {
        let keyString = String(id)

        let savedArray = userSettings.object(forKey: keyString) as? [String]
        if let savedArray = savedArray {
            if savedArray.count == 2 {
                let name = savedArray[0]
                let macAddr = savedArray[1]
                return Element(id: id, name: name, macAddr: macAddr)
            }
        }
        return nil
    }
    
    func getConfiguration() -> [Element]? {
        var configuration : [Element] = []
        
        let lastUsedId = userSettings.integer(forKey: lastUsedIdKeyword)
        if lastUsedId == 0 { //special case - no configuration stored
            return nil
        }
        
        var id = 1
        while id <= lastUsedId {
            if let element = retriveUserSetting(id: id) {
                configuration.append(element)
            }
            id += 1
        }
        
        if configuration.count > 0 {
            return configuration
        } else {
            return nil
        }
    }
}
