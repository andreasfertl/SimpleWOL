//
//  EditViewController.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 02.04.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    var elementToEdit: Element?
    var switchViews: ViewControllerProtocol?

    @IBOutlet weak var uiNameTextBox: UITextField!
    @IBOutlet weak var uiMACaddrTextBox: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uiFormatLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        uiNameTextBox.text = elementToEdit?.name
        uiMACaddrTextBox.text = elementToEdit?.macAddr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let element = elementToEdit {
            if let name = uiNameTextBox.text, let macAddr = uiMACaddrTextBox.text  {
                let elmentToSave = Element(id: element.id, name: name, macAddr: macAddr, buttonType: element.buttonType, uiSwitch: element.uiSwitch)
                switchViews?.switchTo(viewController: .TableView, element: elmentToSave)
                return
            }
        }
        switchViews?.switchTo(viewController: .TableView, element: nil)
    }

    @IBAction func cancelButton(_ sender: Any) {
        switchViews?.switchTo(viewController: .TableView, element: nil)
    }

}

extension EditViewController {
    
    func setProtocols(switchViews: ViewControllerProtocol) {
        self.switchViews = switchViews
    }

    func setElementToEdit(element: Element?) {
        if let element = element {
            elementToEdit = Element(id: element.id, name: element.name.copy() as! String, macAddr: element.macAddr.copy() as! String, buttonType: element.buttonType, uiSwitch: element.uiSwitch)
        }
    }
    
    func validateMACAddrInput(macAddr: String) -> Bool {
        
        let components = macAddr.components(separatedBy: ":")
        let numbers = components.map { return strtoul($0, nil, 16) }
        if numbers.count != 6 {
            return false
        } else {
            return true
        }
    }

}
