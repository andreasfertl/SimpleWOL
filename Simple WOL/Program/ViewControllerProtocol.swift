//
//  ViewControllerProtocol.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 02.04.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

enum ViewController: Int {
    case TableView
    case EditView
}

protocol ViewControllerProtocol: class {
    func switchTo(viewController: ViewController, element: Element?) //with an optional element to handle
}

