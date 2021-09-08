//
//  BoxNetowrking.swift
//  
//
//  Created by Eric Boxer on 8/4/21.
//

import Foundation


// MARK: Enums
public enum BNDispatchQueues:String {
    public typealias RawValue = String
    case UDP = "com.boxnetworking.queue.udp"
    case TCP = "com.boxnetworking.queue.TCP"
}


public enum BNLogLevels:BNLogLevel {
    case DEBUG = 0
    case INFO = 10
    case WARN = 20
    case ERROR = 30
    case FAIL = 40
}

/// BoxNetworking function returns
public enum BNReturnStatus:String {
    case OK = "OK"
    case FAIL = "Failed"
    case ERROR = "Error"
    case MULTICAST_JOIN_ERROR = "Error joining multicast group"
}

// END: Enums


// MARK:Structs

// TODO: Make sure the Multicast Address is an actual Multicast
public struct MulticastAddress {
    private var _address:String
    
    public init(address:String) {
        self._address = address
    }
    
    public var address:String {
        set(newVal) {
            self._address = newVal
        }
        get {
            return self._address
        }
    }
}

// END: Structs

// MARK: Typaliases
public typealias BNLogLevel = Int

// END: Typealiases


