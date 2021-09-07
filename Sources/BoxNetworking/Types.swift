//
//  File.swift
//  
//
//  Created by Eric Boxer on 8/4/21.
//

import Foundation



/// BoxNetworking function returns
public enum BoxNetworkingReturnStatus:String {
    case OK = "OK"
    case FAIL = "Failed"
    case ERROR = "Error"
    case MULTICAST_JOIN_ERROR = "Error joining multicast group"
}




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
