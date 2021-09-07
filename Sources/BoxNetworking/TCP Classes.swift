//
//  TCP Classes.swift
//  
//
//  Created by Eric Boxer on 9/7/21.
//

import Foundation
import CocoaAsyncSocket



public class TCPCLient:NSObject, GCDAsyncSocketDelegate{
    
    var socket:GCDAsyncSocket?
    var deviceIP: String
    var networkInterface: String
    var bindPort: UInt16
    var devicePort:UInt16
    var socketQueue = DispatchQueue(label: "TCPNetworking")
    var incomingDataHandler: ReceiveDataDelegate?
    var timeoutInterval:TimeInterval
    
    
    var tcpNetworkingDelegate:ReceiveDataDelegate?
    
    public init(toIP ipAddress:String, toPort devicePort:UInt16, usingIP networkInterface: String = "", usingPort bindPort:UInt16, timeout:TimeInterval = 1.0) {
        
        self.deviceIP = ipAddress
        self.networkInterface = networkInterface
        self.devicePort = devicePort
        self.bindPort = bindPort
        self.timeoutInterval = timeout
        
        super.init()
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: self.socketQueue)
        
        do{
            if self.networkInterface == ""{
                try self.socket?.connect(toHost: self.deviceIP, onPort: self.devicePort, withTimeout: self.timeoutInterval)
            } else {
                try self.socket?.connect(toHost: self.deviceIP, onPort: self.devicePort, viaInterface: self.networkInterface, withTimeout: self.timeoutInterval)
            }
            
        } catch let error {
            print(error)
        }
        

        
    }
    
    /// Assign a class as to Handle and Process the incoming Data.
    /// - Parameter handler: The name of the Class that handles the incoming Data.
    public func setIncomingDataHandler(to handler:ReceiveDataDelegate){
        self.incomingDataHandler = handler
    }
    
    
//    public func socket
    
    
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print(self.socket?.readData(toLength: 1024, withTimeout: 60.0, tag: 0))

        }
    
    public func sendData(message:Data) {
        self.socket?.write(message, withTimeout: timeoutInterval, tag: 0)
    }
    
}

public class TCPServer:NSObject, GCDAsyncSocketDelegate {
    
}


