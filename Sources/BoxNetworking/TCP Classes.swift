//
//  File.swift
//  
//
//  Created by Eric Boxer on 9/7/21.
//

import Foundation
import CocoaAsyncSocket

class TCPCLient:NSObject, GCDAsyncSocketDelegate {
    
    var socket:GCDAsyncSocket?
    var deviceIP: String
    var networkInterface: String
    var bindPort: UInt16
    var devicePort:UInt16
    var socketQueue = DispatchQueue(label: "TCPNetworking")
    
    
    var tcpNetowrkingDelegate:
    
    override init() {
        
    }
    
    
}

class TCPServer:NSObject, GCDAsyncSocketDelegate {
    
}


