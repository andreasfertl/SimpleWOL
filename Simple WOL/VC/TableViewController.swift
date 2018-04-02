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
    var awake: AwakeProtocol?
    var switchViews: ViewControllerProtocol?
    var buttonMode: ButtonType = ButtonType.switchButton
    var myEditViewController: EditViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditButton(_:)))

        addElement(id: 1, name: "MacbookAir",  macAddr: "84:38:35:55:51:66")
        addElement(id: 2, name: "Macbook",     macAddr: "DC:A9:04:73:1E:4F")
        addElement(id: 3, name: "DeveloperPc", macAddr: "94:C6:91:15:E6:D1")
        addElement(id: 4, name: "AppleTV",     macAddr: "D0:03:4B:EA:0A:FA")
    }

    @IBAction func EditButton(_ sender: Any) {
        //change all icons
        var newButtonMode = ButtonType.editButton
        if buttonMode == .switchButton {
            buttonMode = .editButton
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditButton(_:)))
        } else {
            newButtonMode = .switchButton
            buttonMode = newButtonMode
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditButton(_:)))
        }
        
        for index in 0..<cellElements.count {
            cellElements[index].buttonType = newButtonMode
        }
        
        table.reloadData()
    }
    
    @objc internal func switchChanged(_ sender : UISwitch!) {
        //id transported in sender
        if let element = findElementById(sender.tag) {
            awake?.awake(macAddr: element.macAddr, finishedHandler: { (finished: Bool) -> Void in
                element.uiSwitch.setOn(false, animated: true)
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
                switchViews?.switchTo(viewController: .EditView, element: elementToEdit)
            }
        }
    }
}


extension TableViewController {
    
    func setProtocols(buttonDelegate: AwakeProtocol, switchViews: ViewControllerProtocol) {
        self.awake = buttonDelegate
        self.switchViews = switchViews
    }

    func editOrNewElement(newElement: Element) {
        //handle new element or edit
        if findElementById(newElement.id) != nil {
            //there is an already exisiting one -> just update
            _ = UpdateElementById(newElement.id, name: newElement.name, macAddr: newElement.macAddr)
        } else {
            //doesn´t exist - add the new one
            addElement(id: genNextId(), name: newElement.name, macAddr: newElement.macAddr)
        }
        
        table.reloadData()
    }

    internal func addElement(id: Int, name: String, macAddr: String)
    {
        cellElements.append(Element(id: id, name: name, macAddr: macAddr, buttonType: ButtonType.switchButton, uiSwitch: generateSwitch(id: id)))
    }
    
    internal func findElementById(_ id: Int) -> Element? {
        for index in 0..<cellElements.count {
            if cellElements[index].id == id {
                return cellElements[index]
            }
        }
        return nil
    }
    
    internal func UpdateElementById(_ id: Int, name: String, macAddr: String) -> Bool {
        for index in 0..<cellElements.count {
            if cellElements[index].id == id {
                cellElements[index].name = name
                cellElements[index].macAddr = macAddr
                return true
            }
        }
        return false
    }
    
    internal func genNextId() -> Int {
        return cellElements.count
    }

    
    internal func generateSwitch(id: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = id
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchView.onTintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        
        return switchView
    }

}

