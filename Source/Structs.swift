//
//  Structs.swift
//  BoxNetworking
//
//  Created by Eric Boxer on 1/17/18.
//  Copyright © 2018 Eric Boxer. All rights reserved.
//



// ::::::::::::::::::::::::::::::::::::::
//     Change Log: 2018-03-24 12:24:29
//     Updated: Eric Boxer
//     Notes: Added public struct for IP address as its own type. For future use.
// ::::::::::::::::::::::::::::::::::::::

import Foundation

public struct NetworkInterface {
    public var name: String
    public var ipAddress: String
    
    public init (name: String, ipAddress: String) {
        self.name = name
        self.ipAddress = ipAddress
    }
    
}



/// A simple structure for an IP Address
public struct IPAddress {
    public var ipAddress: String
    
    
    // TODO: Add validity checking.
    public init (ipAddress: String) {
        self.ipAddress = ipAddress
    }
}
