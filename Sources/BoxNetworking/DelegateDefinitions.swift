//
//  Delegate Definitions.swift
//  
//
//  Created by Eric Boxer on 9/7/21.
//

import Foundation



/**
 A delegate protocol for handling incoming data from a socket
 - Parameters:
 - data: That incoming data in raw Data format
 - address: The source IP address
 - port: The source Port
 */
public protocol NetworkingUDPDelegate {
    /// Received Data Handler
    /// - Parameters:
    ///   - data: Socket Data
    ///   - address: IP Address the Data originated from
    ///   - port: Port the Data originated from.
    func receiveData(data:Data, address:String, port:UInt16)
}
