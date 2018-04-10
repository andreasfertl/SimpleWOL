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


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    
    @IBOutlet var uiLabelPCName: WKInterfaceLabel!
    var macAddr : String = ""
    var pcName : String = ""
    var session : WCSession?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        retrieveConfig()
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
    
    func updateMachine(name: String, macAddr: String) {
        self.pcName = name
        self.uiLabelPCName.setText(self.pcName)
        self.macAddr = macAddr
    }
    
    
    func retrieveConfig() {
        session?.sendMessage(["get" : "machine"],
                             replyHandler: { (response) in
                                DispatchQueue.main.async {
                                    //part1 name, part2 macAddr
                                    if response["machine"] != nil {
                                        let (name, macAddr) = self.getMessage(msg: response["machine"] as! String)
                                        self.updateMachine(name: name, macAddr: macAddr)
                                    }
                                }
                             },
                             errorHandler: { (error) in
                                print("Error sending message: %@", error)
                             }
                            )
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didAppear() {
        retrieveConfig()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func sendAwake(macAddr: String) {
        session?.sendMessage(["awake" : macAddr],
                             replyHandler: { (response) in
                                DispatchQueue.main.async {
                                    self.uiLabelPCName.setText("sent awake")
                                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                                        self.uiLabelPCName.setText(self.pcName)
                                    }
                                }
                             },
                             errorHandler: { (error) in
                                DispatchQueue.main.async {
                                    self.uiLabelPCName.setText("error")
                                }
                            }
                            )
    }
    
    @IBAction func awakeButton() {
        sendAwake(macAddr: self.macAddr)
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            let (name, macAddr) = self.getMessage(msg: applicationContext["machine"] as! String)
            self.updateMachine(name: name, macAddr: macAddr)
        }
    }

}
