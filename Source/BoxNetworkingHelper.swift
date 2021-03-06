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
    public static func getNetworkInterfaceAddress() -> [NetworkInterface]? {
        var address : String?
        var interfaces = [NetworkInterface]()
        
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
                let foundInterface = NetworkInterface(name: name, ipAddress: addressCleaned)
                interfaces.append(foundInterface)
            }
        }
        freeifaddrs(ifaddr)
        return interfaces
    }
    
    /// Automatically converts data to a human readable String and removes trailing null characters.
    ///
    /// - Parameter data: Data, typically from a network packet.
    /// - Returns: String representation of data.
    public static func dataToString(data: Data) -> String {
        return String(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!).removeNullCharacters()
    }
    
    /// Checks to see if an IP addres valid
    ///
    /// - Parameter ipAddress: An IP address to test
    /// - Returns: True if the IP adress is valid, false if it's not.
    public static func isValidIPAddress(ipAddress: IPAddress) -> Bool{
        // TODO: Write the function
        // TODO: Make IPv4 and IPv6 compatible.
        
        
        // TODO: Currently always returns true. Make it actually work.
        return true
    }
    
}



