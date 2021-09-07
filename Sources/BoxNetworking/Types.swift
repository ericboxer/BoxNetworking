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
