//
//  Networking.swift
//  Tester
//
//  Created by Eric Boxer on 1/17/18.
//  Copyright © 2018 Eric Boxer. All rights reserved.
//


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
    
    public init(destinationIPAddress ipAddress:String, listenPort: UInt16, sourcePort sendPort: UInt16, networkInterface: String = "" , delegateQueue: String = "socketQueue"){
        self.listenIpAddress = ipAddress
        self.networkInterface = networkInterface
        self.listenPort = listenPort
        self.sendPort = sendPort
        self.returnData = nil
        self.socketQueue = DispatchQueue(label: delegateQueue, qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, target: nil)
        
        
        super.init()
        
        // SOCKETS!!!
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
//        if self.networkInterface == "" {
            let _ = try? self.socket?.bind(toPort: self.listenPort)
//        } else {
//            let _ = try? self.socket?.bind(toPort: self.listenPort, interface: self.networkInterface)
//        }
        let _ = try? self.socket?.beginReceiving()
        
        
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


