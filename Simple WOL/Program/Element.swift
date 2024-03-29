//
//  Element.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 30.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation
import UIKit

enum ButtonType: Int
{
    case switchButton
    case editButton
    case deleteButton
}

class Element {
    var name: String
    var subtitle: String = ""
    var macAddr: String
    var buttonType: ButtonType?
    var uiSwitch: UISwitch?
    var invokedRequest = false
    var showOnAppleWatch = false
    
    init(name: String, macAddr: String, buttonType: ButtonType, uiSwitch: UISwitch, showOnAppleWatch: Bool) {
        self.name = name
        self.macAddr = macAddr
        self.buttonType = buttonType
        self.uiSwitch = uiSwitch
        self.showOnAppleWatch = showOnAppleWatch
    }

    init(name: String, macAddr: String, showOnAppleWatch: Bool) {
        self.name = name
        self.macAddr = macAddr
        self.showOnAppleWatch = showOnAppleWatch
    }
}

