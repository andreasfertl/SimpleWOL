//
//  Awake.swift
//  Simple WOL
//
//  Created by Andreas Fertl on 30.03.18.
//  Copyright © 2018 Andreas Fertl. All rights reserved.
//

import Foundation

protocol AwakeProtocol: class {
    func awakeOnBackgroundThread(macAddr: String, progressHandler: @escaping(Int) -> (), finishedHandler: @escaping(Bool) -> ())
    func awakeOnBackgroundThread(macAddr: String)
}


class AwakeHandler : AwakeProtocol {
    
    func awake(macAddr: String, progressHandler: ((Int) -> ())? = nil, finishedHandler: ((Bool) -> ())? = nil) {
        //try to wake 3 times
        for run in 1...3 {
            if !AwakeMe().Awake(macAddr: macAddr) {
                finishedHandler?(false)
                return
            }
            progressHandler?(run)
            sleep(1)
        }
        
        finishedHandler?(true)
    }
    
    func awakeOnBackgroundThread(macAddr: String, progressHandler: @escaping(Int) -> (), finishedHandler: @escaping(Bool) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.awake(macAddr: macAddr, progressHandler: progressHandler, finishedHandler: finishedHandler)
        }
    }
    
    func awakeOnBackgroundThread(macAddr: String) {
        DispatchQueue.global(qos: .background).async {
            self.awake(macAddr: macAddr)
        }
    }
    
}

class AwakeMe {
    
    func getMacFromString(macAddr: String) -> [CUnsignedChar] {
        let components = macAddr.components(separatedBy: ":")
        let numbers = components.map {
            return strtoul($0, nil, 16)
        }
        
        var mac : [CUnsignedChar] = []
        for number in numbers {
            mac.append(CUnsignedChar(number))
        }
        return mac
    }
    
    func createMagicPacket(macAddr: String) -> [CUnsignedChar] {
        var buffer = [CUnsignedChar]()
        
        for _ in 1...6 {
            buffer.append(0xFF)
        }
        
        let mac = getMacFromString(macAddr: macAddr)
       
        for _ in 1...16 {
            for macNibble in mac {
                buffer.append(macNibble)
            }
        }
        
        return buffer
    }
    
    func openUdpSocket() -> (Int32, Bool) {
        let sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        if sock < 0 {
            return (-1, false) //error, couldn´t create the socket
        } else {
            return (sock, true)
        }
    }
    
    func setBroadcastEnableOnSocket(_ socket: Int32) -> Bool {
        var broadcast = 1
        let intLen = socklen_t(MemoryLayout<Int>.stride)
        if setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &broadcast, intLen) == -1 {
            close(socket)
            return false //couldn´t set broadcast
        }
        return true
    }
    
    func sendMagicPacket(_ socket: Int32, _ macAddr: String) -> Bool {
        var target = sockaddr_in()
        target.sin_family = sa_family_t(AF_INET)
        target.sin_addr.s_addr = inet_addr("255.255.255.255") //fixed for the moment
        target.sin_port = _OSSwapInt16(9) //fixed for the moment
        
        var targetCast = unsafeBitCast(target, to: sockaddr.self)
        let sockaddrLen = socklen_t(MemoryLayout<sockaddr>.stride)
        let packet = createMagicPacket(macAddr: macAddr)
        
        if sendto(socket, packet, packet.count, 0, &targetCast, sockaddrLen) != packet.count {
            return false // couldn´t send
        }
        else {
            return true
        }
    }
    
    func Awake(macAddr: String) -> Bool {
        var retVal = false
        
        let (socket, socketOpen) = openUdpSocket()
        if socketOpen {
            if setBroadcastEnableOnSocket(socket) {
                if sendMagicPacket(socket, macAddr) {
                    retVal = true //everything went fine
                }
            }
        }
        close(socket)
        return retVal
    }
    
}

