//
//  Element.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 30.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation
import UIKit

class Element {
    let id: Int
    let name: String
    let macAddr: String
    var uiSwitch: UISwitch
    
    init(id: Int, name: String, macAddr: String, uiSwitch: UISwitch) {
        self.id = id
        self.name = name
        self.macAddr = macAddr
        self.uiSwitch = uiSwitch
    }
}

