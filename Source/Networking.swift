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

// ::::::::::::::::::::::::::::::::::::::
//     Change Log: 2018-03-24 12:48:39
//     Updated: Eric Boxer
//     Notes: Adding support for multicast
// ::::::::::::::::::::::::::::::::::::::

import Foundation
import CocoaAsyncSocket

public protocol BoxNetworkingUDPDelegate {
    func receiveData(data: Data, address: Data)
}


public protocol BoxNetworkingTCPDelegate {
    func receiveData(data: Data, address: Data)
}


/**
 
 */
public class BoxNetworkingTCP: NSObject, GCDAsyncSocketDelegate {
    var socket: GCDAsyncSocket?
    public var ipAddress: String
    public var networkInterface: String
    var port: UInt16
    var timeout: TimeInterval
    var returnData: String? // Do I need this for TCP?
    var socketQueue: DispatchQueue
    public var boxNetworkingTCPDelegate: BoxNetworkingTCPDelegate?
    
    
    public init(destinationIPAddress ipAddress:String, port: UInt16, networkInterface: String = "", timeout: TimeInterval = 1 ) {

        self.ipAddress = ipAddress
        self.networkInterface = networkInterface
        self.port = port
        self.timeout = timeout
        self.returnData = nil
        self.socketQueue = DispatchQueue.main
        
        super.init()
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: self.socketQueue)
        
        do {
            if self.networkInterface != "" {
                try self.socket?.connect(toHost: self.ipAddress, onPort: self.port, viaInterface: self.networkInterface, withTimeout:self.timeout)
            } else {
                try self.socket?.connect(toHost: self.ipAddress, onPort: self.port, withTimeout: self.timeout)
            }
        } catch let error {
            print(error)
        }
    }
    deinit {
        self.socket?.disconnect()
    }
    
    
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
    
    // MARK: Multicast
    public func joinMulticastGroup(multicastGroupAddress: IPAddress, interface: String = "") {

        do {
            if interface != "" {
                try self.socket?.joinMulticastGroup(multicastGroupAddress.ipAddress, onInterface: interface)
            } else {
                try self.socket?.joinMulticastGroup(multicastGroupAddress.ipAddress)
                
            }
        } catch {
            print("cannot join multicast group")
        }
    }
    
    public func leaveMulticastGroup(multicastGroupAddress: IPAddress, interface: String = "") {
        do {
            if interface != "" {
                try self.socket?.leaveMulticastGroup(multicastGroupAddress.ipAddress, onInterface: interface)
            } else {
                try self.socket?.leaveMulticastGroup(multicastGroupAddress.ipAddress)
            }
        } catch {
            print("Cannot leave multicast address")
        }
        
    }
    
}


