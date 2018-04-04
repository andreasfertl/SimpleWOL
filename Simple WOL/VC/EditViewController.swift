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
    var idx : Int = 0
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
        uiFormatLabel.isHidden = true
        if newElement {
            uiTitle.text = "New host"
        } else {
            uiTitle.text = "Edit host"
        }
    }

    @IBAction func cancelButon(_ sender: Any) {
        switchViews?.switchTo(viewController: .TableView, element: nil, idx: 0, newElement: false)
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
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let name = uiNameTextBox.text, let macAddr = uiMACaddrTextBox.text  {
            let macAddr = macAddr.uppercased()
            if validateMACAddrInput(macAddr: macAddr){
                let elmentToSave = Element(name: name, macAddr: macAddr)
                switchViews?.switchTo(viewController: .TableView, element: elmentToSave, idx: idx, newElement: false)
                return
            } else { // not ok
                uiFormatLabel.text = "Wrong format, use: 00:11:22:33:44:AA"
                uiFormatLabel.isHidden = false
                return
            }
        }
    }



}

extension EditViewController {
    
    func setProtocols(switchViews: ViewControllerProtocol) {
        self.switchViews = switchViews
    }

    func setElementToEdit(element: Element?, idx: Int, newElement: Bool) {
        if let element = element {
            self.newElement = newElement
            self.idx = idx
            elementToEdit = Element(name: element.name, macAddr: element.macAddr)
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
