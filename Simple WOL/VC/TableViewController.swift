//
//  TableViewController.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 31.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var cellElements: [Element] = []
    var configuration: ConfigurationProtocol?
    var awake: AwakeProtocol?
    var switchViews: ViewControllerProtocol?
    var buttonMode: ButtonType = ButtonType.switchButton
    var myEditViewController: EditViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditButton(_:)))
        
        if let configuration = configuration?.getConfiguration() {
            for element in configuration {
               addElement(name: element.name, macAddr: element.macAddr)
            }
        }
        
        //addElement(id: 1, name: "DeveloperPc", macAddr: "94:C6:91:15:E6:D1")
        //addElement(id: 2, name: "MacbookAir",  macAddr: "84:38:35:55:51:66")
        //addElement(id: 3, name: "Macbook",     macAddr: "DC:A9:04:73:1E:4F")
        //addElement(id: 4, name: "AppleTV",     macAddr: "D0:03:4B:EA:0A:FA")
    }

    @IBAction func EditButton(_ sender: Any) {
        //change all icons
        var newButtonMode = ButtonType.editButton
        if buttonMode == .switchButton {
            buttonMode = .editButton
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditButton(_:)))
            navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(NewButton(_:)))
        } else {
            newButtonMode = .switchButton
            buttonMode = newButtonMode
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditButton(_:)))
            navigationItem.leftBarButtonItem = nil
        }
        
        for index in 0..<cellElements.count {
            cellElements[index].buttonType = newButtonMode
        }
        
        table.reloadData()
    }
    
    @IBAction func NewButton(_ sender: Any) {
        switchViews?.switchTo(viewController: .EditView, element: Element(name: "name", macAddr: "00:11:22:33:44:55"), idx: genNextIdx(), newElement: true)
    }

    
    @objc internal func switchChanged(_ sender : UISwitch!) {
        //id transported in sender
        if let element = findElementByIdx(sender.tag) {
            awake?.awake(macAddr: element.macAddr, finishedHandler: { (finished: Bool) -> Void in
                element.uiSwitch!.setOn(false, animated: true)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellElements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)

        if indexPath.row < cellElements.count {
            let element = cellElements[indexPath.row]
            cell.textLabel?.text = element.name
            if element.buttonType == ButtonType.switchButton {
                cell.accessoryView = element.uiSwitch
            } else {
                cell.accessoryView = nil
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < cellElements.count {
            let elementToEdit = cellElements[indexPath.row]
            if elementToEdit.buttonType == .editButton {
                switchViews?.switchTo(viewController: .EditView, element: elementToEdit, idx: indexPath.row, newElement: false)
            }
        }
    }
    
    //return only edit able if in edit mode
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return buttonMode == .editButton
    }

    //delete swipe action
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < cellElements.count {
                configuration?.deleteConfig(element: cellElements[indexPath.row], idx: indexPath.row)
                cellElements.remove(at: indexPath.row)
                table.reloadData()
            }
        }
    }
}


extension TableViewController {
    
    func setProtocols(configuration: ConfigurationProtocol?, buttonDelegate: AwakeProtocol, switchViews: ViewControllerProtocol) {
        self.awake = buttonDelegate
        self.switchViews = switchViews
        self.configuration = configuration
    }

    func editOrNewElement(newElement: Element, idx: Int) {
        //handle new element or edit
        if findElementByIdx(idx) != nil {
            //there is an already exisiting one -> just update
            let updated = UpdateElementByIdx(idx, name: newElement.name, macAddr: newElement.macAddr)
            if updated {
                let retVal = findElementByIdx(idx)
                configuration?.saveConfig(element: retVal, idx: idx)
            }
        } else {
            //doesn´t exist - add the new one
            addElement(name: newElement.name, macAddr: newElement.macAddr, buttonType: buttonMode)
            //and save
            let retVal = findElementByIdx(idx)
            configuration?.saveConfig(element: retVal, idx: idx)
        }
        
        table.reloadData()
    }

    internal func addElement(name: String, macAddr: String)
    {
        cellElements.append(Element(name: name, macAddr: macAddr, buttonType: ButtonType.switchButton, uiSwitch: generateSwitch(idx: genNextIdx())))
    }

    internal func addElement(name: String, macAddr: String, buttonType: ButtonType)
    {
        cellElements.append(Element(name: name, macAddr: macAddr, buttonType: buttonType, uiSwitch: generateSwitch(idx: genNextIdx())))
    }

    internal func findElementByIdx(_ idx: Int) -> Element? {
        if idx < cellElements.count {
            return cellElements[idx]
        }
        return nil
    }
    
    internal func UpdateElementByIdx(_ idx: Int, name: String, macAddr: String) -> Bool {
        if idx < cellElements.count {
                var changed = false
                if cellElements[idx].name != name {
                    cellElements[idx].name = name
                    changed = true
                }
                if cellElements[idx].macAddr != macAddr {
                    cellElements[idx].macAddr = macAddr
                    changed = true
                }
                return changed
        }
        return false
    }
    
    internal func genNextIdx() -> Int {
        return cellElements.count
    }

    internal func generateSwitch(idx: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = idx
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchView.onTintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        
        return switchView
    }

}

