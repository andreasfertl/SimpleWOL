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
    
    func retrieveConfig() {
        session?.sendMessage(["get" : "machine"],
                             replyHandler: { (response) in
                                DispatchQueue.main.async {
                                    //part1 name, part2 macAddr
                                    if response["machine"] != nil {
                                        let name = response["machine"] as! String
                                        let machine : [String] = name.components(separatedBy: "#")
                                        if machine.count > 0 { //name
                                            self.pcName = machine[0]
                                            self.uiLabelPCName.setText(self.pcName)
                                        }
                                        if machine.count > 1 { //machaddr
                                            self.macAddr = machine[1]
                                        }
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


}
