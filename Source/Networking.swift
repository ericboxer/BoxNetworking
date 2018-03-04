//
//  Networking.swift
//  Tester
//
//  Created by Eric Boxer on 1/17/18.
//  Copyright © 2018 Eric Boxer. All rights reserved.
//

// ::::::::::::::::::::::::::::::::::::::
//     Change Log: 2018-03-04 12:51:26
//     Updated: Eric Boxer
//     Notes: added deinit function
// ::::::::::::::::::::::::::::::::::::::

import Foundation
import CocoaAsyncSocket

public protocol BoxNetworkingUDPDelegate {
    func receiveData(data: Data, address: Data)
}

public class BoxNetworkingUDP: NSObject, GCDAsyncUdpSocketDelegate {
    
    var socket: GCDAsyncUdpSocket?
    public var listenIpAddress: String
    public var networkInterface: String
    var sendPort: UInt16
    var listenPort: UInt16
    var returnData: String?
    var socketQueue: DispatchQueue
    public var boxNetworkingUDPDelegate: BoxNetworkingUDPDelegate?
    
    public init(destinationIPAddress ipAddress:String, listenPort: UInt16, sourcePort sendPort: UInt16, networkInterface: String = "" ){
        self.listenIpAddress = ipAddress
        self.networkInterface = networkInterface
        self.listenPort = listenPort
        self.sendPort = sendPort
        self.returnData = nil
        self.socketQueue = DispatchQueue.main
        
        
        super.init()
        
        // SOCKETS!!!
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.socketQueue)
        
        do {
            if self.networkInterface != "" {
                try self.socket?.bind(toPort: self.listenPort, interface: self.networkInterface)
            } else {
                try self.socket?.bind(toPort: self.listenPort)
            }
        } catch let error {
            print(error)
        }
        do {
            try  self.socket?.beginReceiving()
        } catch let error {
            print (error)
        }
        
        
    }
    
    deinit {
        self.socket?.close()
    }
    
    // MARK: Receiving Data
    // When we receive a packet....
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        boxNetworkingUDPDelegate?.receiveData(data: data, address: address)
    }

    // MARK: Sending Data
    /**
     Send UDP message of type String
     
     -parameter message: String of what you want to send
     */
    public func sendUDP(message: String) {
        self.sendUDPData(message: message.data(using: String.Encoding.utf8)!)
    }
    
    /**
     Send UDP message of type Data
     
     -parameter message: Data of what you want to send
     */
    public func sendUDPData(message: Data) {
        socket?.send(message, toHost: self.listenIpAddress, port: self.sendPort, withTimeout: 4, tag: 0)
    }
    
}


