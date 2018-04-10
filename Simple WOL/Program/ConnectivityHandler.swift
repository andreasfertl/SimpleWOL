//
//  ConnectivityHandler.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 08.04.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation
import WatchConnectivity

struct machine {
    var macAddr: String
    var name: String
    var showOnAppleWatch: Bool
}

protocol watchProtocol: class {
    func getConfiguredMachines() -> [machine]?
    func awakeThis(macAddr: String)
}
protocol watchPushProtocol: class {
    func updateApplicationContext(element: Element)
}

class ConnectivityHandler : NSObject, WCSessionDelegate, watchPushProtocol {
    
    var session = WCSession.default
    var watchPl : watchProtocol?
    var available = WCSession.isSupported()
    
    override init() {
        super.init()
        
        if (available) {
            session.delegate = self
            session.activate()
        }
    }
    
    func setWatchProtocol(watchProtocol: watchProtocol) {
        watchPl = watchProtocol
    }
    
    func isAvailable() -> Bool {
        return available
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["get"] as? String == "machine" {
            if let machines = watchPl?.getConfiguredMachines() {
                for machine in machines {
                    if machine.showOnAppleWatch {
                        replyHandler(["machine" : machine.name + "#" + machine.macAddr])
                        //only the first one is on AppleWatch
                        return
                    }
                }
            }
        } else if message["awake"] != nil {
            let macAddr = message["awake"] as! String
            watchPl?.awakeThis(macAddr: macAddr)
            replyHandler(["awake" : "OK"])
        }

    }
    
    func updateApplicationContext(element: Element) {
        do {
            try session.updateApplicationContext(["machine" : element.name + "#" + element.macAddr])
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
        }
    }
}
