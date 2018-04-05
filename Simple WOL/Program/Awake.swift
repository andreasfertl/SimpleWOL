//
//  AWake.swift
//
//  Created by Jesper Lindberg on 2016-10-03.
//  Copyright © 2016 Jesper Lindberg. All rights reserved.
//

import Foundation

class AwakeHandler : AwakeProtocol {
    
    func awake(macAddr: String, progressHandler: @escaping(Int) -> Void, finishedHandler: @escaping(Bool) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            //try to wake 3 times
            for run in 1...3 {
                if !AwakeMe().Awake(macAddr: macAddr) {
                    finishedHandler(false)
                    return
                }
                progressHandler(run)
                sleep(1)
            }
            
            finishedHandler(true)
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
        
        // Create header with 6 times 0xFF
        for _ in 1...6 {
            buffer.append(0xFF)
        }
        
        let mac = getMacFromString(macAddr: macAddr)
        // Repeat MAC address 16 times
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
            return (-1, true) //error, couldn´t create the socket
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

