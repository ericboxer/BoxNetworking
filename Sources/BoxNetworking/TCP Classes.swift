//
//  TCP Classes.swift
//  This is part of the BoxNetworking "Framework"
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
    var socketQueue = DispatchQueue(label: BNDispatchQueues.TCP.rawValue)
    var incomingDataHandler: BNReceiveDataDelegate?
    var timeoutInterval:TimeInterval
    
    var tcpNetworkingDelegate:BNReceiveDataDelegate?
    
    public init(toIP ipAddress:String, toPort devicePort:UInt16, usingIP networkInterface: String = "", usingPort bindPort:UInt16, timeout:TimeInterval = 1.0) {
        
        self.deviceIP = ipAddress
        self.networkInterface = networkInterface
        self.devicePort = devicePort
        self.bindPort = bindPort
        self.timeoutInterval = timeout
        
        super.init()
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: self.socketQueue)

        // Create the connection. 
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
    
    deinit {
        self.socket?.disconnect()
    }
    

    public func sendData(message:Data) {
        self.socket?.write(message, withTimeout: self.timeoutInterval, tag: 0)
    }
    
    private func readData(data:Data) {
        self.incomingDataHandler?.receiveData(data: data, address: self.deviceIP, port: self.devicePort)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    /// Assign a class as to Handle and Process the incoming Data.
    /// - Parameter handler: The name of the Class that handles the incoming Data.
    public func setIncomingDataHandler(to handler:BNReceiveDataDelegate){
        self.incomingDataHandler = handler
    }
    
    // MARK: Socket Functions
    // These functions are used by CocoaAsync to pass data along.
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        readData(data: data)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        guard let er = err else {
            return
        }
        print(er)
    }
}
