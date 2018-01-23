//
//  Structs.swift
//  BoxNetworking
//
//  Created by Eric Boxer on 1/17/18.
//  Copyright © 2018 Eric Boxer. All rights reserved.
//

import Foundation

public struct NetworkInterface {
    public var name: String
    public var ipAddress: String
    
    public init (name: String, ipAddress: String) {
        self.name = name
        self.ipAddress = ipAddress
    }
    
}
