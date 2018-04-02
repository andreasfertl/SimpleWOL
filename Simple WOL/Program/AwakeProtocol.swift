//
//  AwakeProtocol.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 30.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

protocol AwakeProtocol: class {
    func awake(macAddr: String, finishedHandler: @escaping(Bool) -> Void)
}

