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
    //func deleteConfig(element: Element)
}

class Configuration : ConfigurationProtocol {

    let userSettings = UserDefaults.standard
    var configElements : [Element] = []
    let numberOfElementsKeyword = "numberOfElements"

    func saveConfig(element: Element?) {
        if let element = element {
            let array = [String(element.id), element.name, element.macAddr]

            for idx in 0..<configElements.count {
                if configElements[idx].id == element.id { //found an already existing with this id -> just update
                    //converting our element to a string representation to be able to store it
                    let idxString = String(idx)
                    userSettings.set(array, forKey: idxString)
                    return
                }
            }
            //didn´t find this one - so must be new -> add an additional one
            configElements.append(element)
            let idxString = String(configElements.count)
            userSettings.set(array, forKey: idxString)
            
            //and we need to keep our number of elements up to data, culd have been changed
            userSettings.set(configElements.count, forKey: numberOfElementsKeyword)
        }
    }
    
//    func deleteConfig(element: Element){
//        //find the one we are looking for
//        for idx in 0..<configElements.count {
//            if configElements[idx].id == element.id { //found the corresponding one
//                configElements.remove(at: idx)
//                break
//            }
//        }
//        
//        //rewrite ids
//        for index in 0..<configElements.count {
//            configElements[index].id = index
//        }
//
//        //and again we need to keep our number of elements up to data
//        userSettings.set(configElements.count, forKey: numberOfElementsKeyword)
//    }
    
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
