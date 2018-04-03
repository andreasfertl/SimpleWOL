//
//  EditViewController.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 02.04.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {

    var elementToEdit: Element?
    var switchViews: ViewControllerProtocol?
    var newElement: Bool = false

    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiNameTextBox: UITextField!
    @IBOutlet weak var uiMACaddrTextBox: UITextField!
    @IBOutlet weak var uiFormatLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiNameTextBox.delegate = self
        uiMACaddrTextBox.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        uiNameTextBox.text = elementToEdit?.name
        uiMACaddrTextBox.text = elementToEdit?.macAddr
        if newElement {
            uiTitle.text = "New host"
        } else {
            uiTitle.text = "Edit host"
        }
    }

    @IBAction func cancelButon(_ sender: Any) {
        switchViews?.switchTo(viewController: .TableView, element: nil, newElement: false)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if newElement {
            if textField == uiNameTextBox {
                uiNameTextBox.text = ""
            } else if textField == uiMACaddrTextBox {
                uiMACaddrTextBox.text = ""
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let element = elementToEdit {
            if let name = uiNameTextBox.text, let macAddr = uiMACaddrTextBox.text  {
                let elmentToSave = Element(id: element.id, name: name, macAddr: macAddr)
                switchViews?.switchTo(viewController: .TableView, element: elmentToSave, newElement: false)
                return
            }
        }
        switchViews?.switchTo(viewController: .TableView, element: nil, newElement: false)
    }



}

extension EditViewController {
    
    func setProtocols(switchViews: ViewControllerProtocol) {
        self.switchViews = switchViews
    }

    func setElementToEdit(element: Element?, newElement: Bool) {
        if let element = element {
            self.newElement = newElement
            elementToEdit = Element(id: element.id, name: element.name, macAddr: element.macAddr)
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
