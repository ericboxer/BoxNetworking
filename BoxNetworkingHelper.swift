//
//  BoxNetworkingHelper.swift
//  BoxNetworking
//
//  Created by Eric Boxer on 1/17/18.
//  Copyright © 2018 Eric Boxer. All rights reserved.
//

import Foundation

public class BoxNetworkingHelpers {

    
    /**
        Returns an array of Network interface names and IPv4 Addresses
     */
    public static func getNetworkInterfaceAddress() -> [BoxNetworkInterface]? {
        var address : String?
        var interfaces = [BoxNetworkInterface]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                
                address = String(cString: hostname)
                
                guard let addressCleaned = address else {return nil }
                let foundInterface = BoxNetworkInterface(name: name, ipAddress: addressCleaned)
                interfaces.append(foundInterface)
            }
        }
        freeifaddrs(ifaddr)
        return interfaces
    }
    
}



