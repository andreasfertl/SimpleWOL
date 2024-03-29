//
//  TableViewController.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 31.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, watchProtocol {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var cellElements: [Element] = []
    var configuration: ConfigurationProtocol?
    var awake: AwakeProtocol?
    var switchViews: ViewControllerProtocol?
    var buttonMode: ButtonType = ButtonType.switchButton
    var myEditViewController: EditViewController?
    var watchpushProtocol: watchPushProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.rowHeight = 75.0
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditButton(_:)))
        
        if let configuration = configuration?.getConfiguration() {
            for element in configuration {
                addElement(name: element.name, macAddr: element.macAddr, showOnAppleWatch: element.showOnAppleWatch)
            }
        }
    }


    @IBAction func EditButton(_ sender: Any) {
        //change all icons
        var newButtonMode = ButtonType.editButton
        if buttonMode == .switchButton {
            buttonMode = .editButton
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditButton(_:)))
            navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(NewButton(_:)))
            tableView.allowsSelection = true
        } else {
            newButtonMode = .switchButton
            buttonMode = newButtonMode
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditButton(_:)))
            navigationItem.leftBarButtonItem = nil
            tableView.allowsSelection = false
        }
        
        for index in 0..<cellElements.count {
            cellElements[index].buttonType = newButtonMode
        }
        
        tableView.reloadData()
    }
    
    @IBAction func NewButton(_ sender: Any) {
        switchViews?.switchTo(viewController: .EditView, element: Element(name: "name", macAddr: "00:11:22:33:44:55", showOnAppleWatch: false), idx: genNextIdx(), newElement: true)
    }

    
    @objc internal func switchChanged(_ sender : UISwitch!) {
        //id transported in sender
        if let element = findElementByIdx(sender.tag) {
            // don´t request a new one as long i am not finished!
            awakeThis(element: element)
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
            cell.detailTextLabel?.text = element.subtitle
            if element.buttonType == ButtonType.switchButton {
                //update the tag to correspond always the indexpath
                element.uiSwitch?.tag = indexPath.row
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
                tableView.reloadData()
            }
        }
    }
}


extension TableViewController {
    
    func setProtocols(configuration: ConfigurationProtocol?, buttonDelegate: AwakeProtocol, switchViews: ViewControllerProtocol, watchpushProtocol: watchPushProtocol?) {
        self.awake = buttonDelegate
        self.switchViews = switchViews
        self.configuration = configuration
        self.watchpushProtocol = watchpushProtocol
    }
    
    func getConfiguredMachines() -> [machine]? {
        var machines = [machine]()
        
        for element in cellElements {
            machines.append(machine(macAddr: element.macAddr, name: element.name, showOnAppleWatch: element.showOnAppleWatch))
        }
        return machines
    }
    
    func awakeThis(macAddr: String) {
        if let awakeme = findElementByMacAddr(macAddr) {
            awakeThis(element: awakeme)
        }
    }
    
    func awakeThis(element: Element) {
        if !element.invokedRequest {
            awake?.awakeOnBackgroundThread(macAddr: element.macAddr, progressHandler: { (count: Int) -> Void in
                DispatchQueue.main.async {
                    element.uiSwitch!.thumbTintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                    element.invokedRequest = true
                    element.subtitle = "started sending WOL packages: \(count)"
                    self.tableView.reloadData()
                }
            }, finishedHandler: { (finished: Bool) -> Void in
                DispatchQueue.main.async {
                    if finished {
                        element.subtitle = "done"
                    } else {
                        element.subtitle = "error couldn´t send"
                    }
                    self.tableView.reloadData()
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                        DispatchQueue.main.async {
                            element.subtitle = ""
                            element.uiSwitch!.setOn(true, animated: true)
                            element.uiSwitch!.thumbTintColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
                            element.invokedRequest = false
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                //just set it back since we are busy
                element.uiSwitch?.setOn(false, animated: false)
            }
        }
    }

    
    func editOrNewElement(newElement: Element, idx: Int) {
        //handle new element or edit
        if findElementByIdx(idx) != nil {
            //there is an already exisiting one -> just update
            let updated = UpdateElementByIdx(idx, name: newElement.name, macAddr: newElement.macAddr, showOnAppleWatch: newElement.showOnAppleWatch)
            if updated {
                let retVal = findElementByIdx(idx)
                configuration?.saveConfig(element: retVal, idx: idx)
            }
        } else {
            //doesn´t exist - add the new one
            addElement(name: newElement.name, macAddr: newElement.macAddr, buttonType: buttonMode, showOnAppleWatch: newElement.showOnAppleWatch)
            //and save
            let retVal = findElementByIdx(idx)
            configuration?.saveConfig(element: retVal, idx: idx)
        }
        
        if newElement.showOnAppleWatch {
            //only one at the moment
            for index in 0..<cellElements.count {
                if index != idx {
                    //since i am now shown on apple watch remove it here if active
                    if cellElements[index].showOnAppleWatch {
                        let updated = UpdateElementByIdx(index, name: cellElements[index].name, macAddr: cellElements[index].macAddr, showOnAppleWatch: false)
                        if updated {
                            let retVal = findElementByIdx(index)
                            configuration?.saveConfig(element: retVal, idx: index)
                        }
                    }
                }
            }
        }

        
        tableView.reloadData()
    }

    internal func addElement(name: String, macAddr: String, showOnAppleWatch: Bool)
    {
        cellElements.append(Element(name: name, macAddr: macAddr, buttonType: ButtonType.switchButton, uiSwitch: generateSwitch(idx: genNextIdx()), showOnAppleWatch: showOnAppleWatch))
    }

    internal func addElement(name: String, macAddr: String, buttonType: ButtonType, showOnAppleWatch: Bool)
    {
        cellElements.append(Element(name: name, macAddr: macAddr, buttonType: buttonType, uiSwitch: generateSwitch(idx: genNextIdx()), showOnAppleWatch: showOnAppleWatch))
    }

    internal func findElementByIdx(_ idx: Int) -> Element? {
        if idx < cellElements.count {
            return cellElements[idx]
        }
        return nil
    }
    
    internal func findElementByMacAddr(_ macAddr: String) -> Element? {
        for element in cellElements {
            if element.macAddr == macAddr {
                return element
            }
        }
        return nil
    }

    
    internal func UpdateElementByIdx(_ idx: Int, name: String, macAddr: String, showOnAppleWatch: Bool) -> Bool {
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
                if cellElements[idx].showOnAppleWatch != showOnAppleWatch {
                    cellElements[idx].showOnAppleWatch = showOnAppleWatch
                    changed = true
                    
                    //this one has to be shown on apple watch inform it
                    if showOnAppleWatch {
                        self.watchpushProtocol?.updateApplicationContext(element: cellElements[idx])
                    }
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
        switchView.setOn(true, animated: true)
        switchView.tag = idx
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchView.onTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        switchView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        switchView.thumbTintColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        
        return switchView
    }

}

