//
//  TableViewController.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 31.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var cellElements: [Element] = []
    var buttonPressedDeleagte: ButtonProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addElement(id: 1, name: "1", macAddr: "addadssdaf")
        addElement(id: 2, name: "DeveloperPc", macAddr: "94:C6:91:15:E6:D1")
        addElement(id: 3, name: "3", macAddr: "addadssdaf")
        addElement(id: 4, name: "4", macAddr: "addadssdaf")
        addElement(id: 5, name: "5", macAddr: "addadssdaf")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellElements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)

        if indexPath.row < cellElements.count {
            let element = cellElements[indexPath.row]
            cell.textLabel?.text = element.name
            cell.accessoryView = element.uiSwitch
        }
        return cell
    }
    
}


extension TableViewController {
    
    func setButtonCallback(buttonPressedDeleagte: ButtonProtocol) {
        self.buttonPressedDeleagte = buttonPressedDeleagte
    }
    
    internal func addElement(id: Int, name: String, macAddr: String)
    {
        cellElements.append(Element(id: id, name: name, macAddr: macAddr, uiSwitch: GenerateSwitch(id: id)))
    }
    
    @objc internal func switchChanged(_ sender : UISwitch!) {
        let id = sender.tag //id transported in sender
        for index in 0..<cellElements.count {
            let element = cellElements[index]
            if element.id == id {
                buttonPressedDeleagte?.buttonPress(macAddr: element.macAddr, finishedHandler: { (finished: Bool) -> Void in
                    element.uiSwitch.setOn(false, animated: true)
                })
            }
        }
    }
    
    internal func GenerateSwitch(id: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = id
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchView.onTintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        
        return switchView
    }
}

