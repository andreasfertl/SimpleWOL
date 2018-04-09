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
}

protocol watchProtocol: class {
    func getConfiguredMachines() -> [machine]?
    func awakeThis(macAddr: String)
}

class ConnectivityHandler : NSObject, WCSessionDelegate {
    
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
                if machines.count > 0 {
                    replyHandler(["machine" : machines[0].name + "#" + machines[0].macAddr])
                }
            }
        } else if message["awake"] != nil {
            let macAddr = message["awake"] as! String
            watchPl?.awakeThis(macAddr: macAddr)
            replyHandler(["awake" : "OK"])
        }

    }
    
}
