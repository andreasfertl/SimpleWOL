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
    @IBOutlet weak var uiShowOnAppleWatchSwitch: UISwitch!
    
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
        if elementToEdit?.showOnAppleWatch == true {
            uiShowOnAppleWatchSwitch.setOn(true, animated: false)
        } else {
            uiShowOnAppleWatchSwitch.setOn(false, animated: false)
        }
        
        uiShowOnAppleWatchSwitch.onTintColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        uiShowOnAppleWatchSwitch.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        uiShowOnAppleWatchSwitch.thumbTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
                let elmentToSave = Element(name: name, macAddr: macAddr, showOnAppleWatch: uiShowOnAppleWatchSwitch.isOn)
                switchViews?.switchTo(viewController: .TableView, element: elmentToSave, idx: idx, newElement: false)
                return
            } else { // not ok
                uiFormatLabel.text = "Wrong format, use: 00:11:22:33:44:AA"
                uiFormatLabel.isHidden = false
                return
            }
        }
    }
    
    
    @IBAction func uiSwitchShowOnAppleWatch(_ sender: UISwitch) {
        elementToEdit?.showOnAppleWatch = sender.isOn
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
            elementToEdit = Element(name: element.name, macAddr: element.macAddr, showOnAppleWatch: element.showOnAppleWatch)
        }
    }
    
    func validateChar(_ char: Character) -> Bool {
        switch char {
        case "0":
            return true
        case "1":
            return true
        case "2":
            return true
        case "3":
            return true
        case "4":
            return true
        case "5":
            return true
        case "6":
            return true
        case "7":
            return true
        case "8":
            return true
        case "9":
            return true
        case "A":
            return true
        case "B":
            return true
        case "C":
            return true
        case "D":
            return true
        case "E":
            return true
        case "F":
            return true

        default:
            return false
        }
    }
    
    func validateMACAddrInput(macAddr: String) -> Bool {        
        
        //is it divided in 6 sub"strings" 00:11:22:33:44:AA
        let components = macAddr.components(separatedBy: ":")
        let numbers = components.map { return strtoul($0, nil, 16) }
        if numbers.count != 6 {
            return false
        }
        
        //in every substring should be only 2 characters
        for numberString in components {
            if numberString.count != 2 {
                return false
            }
            //only runs twice
            for char in numberString {
                if !validateChar(char) {
                    return false
                }
            }
        }
        //ok all testst passed
        return true
    }

}
