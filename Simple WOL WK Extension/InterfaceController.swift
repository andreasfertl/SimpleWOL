//
//  InterfaceController.swift
//  Simple WOL WK Extension
//
//  Created by Andreas Fertl on 06.04.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class Settings {
    let userSettings = UserDefaults.standard
    let userSettingKey = "0"

    func retrieveConfigLocally() -> Machine {
        let machine = Machine()
        
        let savedArray = userSettings.object(forKey: userSettingKey) as? [String]
        if let savedArray = savedArray {
            if savedArray.count == 2 {
                machine.pcName = savedArray[0]
                machine.macAddr = savedArray[1]
                return machine
            }
        }
        return machine
    }
    
    func storeConfigLocally(name: String, macAddr: String) {
        let array = [name, macAddr]
        userSettings.set(array, forKey: userSettingKey)
    }
}

class Machine {
    var macAddr : String = ""
    var pcName : String = ""
    
    func update(name: String, macAddr: String, storeSettings: Settings?) {
        pcName = name
        self.macAddr = macAddr
        
        if let storeSettings = storeSettings {
            storeSettings.storeConfigLocally(name: name, macAddr: macAddr)
        }
    }
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var uiLabelPCName: WKInterfaceLabel!
    var session : WCSession?
    var machine : Machine?
    let settings = Settings()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        machine = settings.retrieveConfigLocally()
        if machine?.pcName != "" {
            uiLabelPCName.setText(machine!.pcName)
        }

        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        retrieveConfig()
    }
    
    override func didAppear() {
        retrieveConfig()
    }
    
    @IBAction func awakeButton() {
        sendAwake(macAddr: self.machine?.macAddr)
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handleReceivedMachineUpdate(response: applicationContext)
        }
    }

}



extension InterfaceController {
    
    func resetName(_ name: String?){
        if let name = name {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                self.uiLabelPCName.setText(name)
            }
        }
    }
    
    func sendAwake(macAddr: String?) {
        if let macAddr = macAddr {
            self.uiLabelPCName.setText("sent awake signal")
            self.resetName(self.machine?.pcName)
            //send locally
            AwakeHandler().awakeOnBackgroundThread(macAddr: macAddr)
            //and remote
            session?.sendMessage(["awake" : macAddr],
                                 replyHandler: { (response) in
                                 },
                                 errorHandler: { (error) in
                                    DispatchQueue.main.async {
                                        self.uiLabelPCName.setText("error")
                                        self.resetName(self.machine?.pcName)
                                    }
                                 }
                                )
        }
    }
    
    func getMessage(msg: String) -> (String, String) {
        let machine : [String] = msg.components(separatedBy: "#")
        var name = ""
        var macAddr = ""
        
        if machine.count > 0 { //name
            name = machine[0]
        }
        if machine.count > 1 { //machaddr
            macAddr = machine[1]
        }
        return (name, macAddr)
    }
    
    func handleReceivedMachineUpdate(response: [String : Any]) {
        let (name, macAddr) = self.getMessage(msg: response["machine"] as! String)
        self.machine?.update(name: name, macAddr: macAddr, storeSettings: self.settings)
        self.uiLabelPCName.setText(self.machine?.pcName)
    }
    
    func retrieveConfig() {
        session?.sendMessage(["get" : "machine"],
                             replyHandler: { (response) in
                                DispatchQueue.main.async {
                                    //part1 name, part2 macAddr
                                    if response["machine"] != nil {
                                        self.handleReceivedMachineUpdate(response: response)
                                    }
                                }
                             },
                             errorHandler: { (error) in
                                print("Error sending message: %@", error)
                             }
                             )
    }
    
}
