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
    
    // Private vars
    
    var socket:GCDAsyncSocket?
    var deviceIP: String
    var networkInterface: String
    var bindPort: UInt16
    var devicePort:UInt16
    var socketQueue = DispatchQueue(label: BNDispatchQueues.TCP.rawValue)
    var logLevel:BNLogLevels = .INFO

    var timeoutInterval:TimeInterval
    
    
    // Delegate Assignments
    var incomingDataHandler: BNReceiveDataDelegate?
    var loggingDelegate: BNLoggingDelegate?
    
    
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
            self.info("TCP Connection established to \(self.deviceIP):\(self.devicePort)")
        } catch let error {
            self.error(String(describing:error))
        }
    }
    
    deinit {
        self.socket?.disconnect()
    }
    
    
    // MARK: Public User Functions
    // These are functions exposed to the user

    /// Assign a class to delegate the processing of incoming Data.
    /// - Parameter to: The data handling delegate
    public func setIncomingDataHandler(to delegate:BNReceiveDataDelegate){
        self.incomingDataHandler = delegate
    }
    
    /// Assign a class to delegate logging to.
    /// - Parameter to: The logging delegate class
    public func setLogDelegate(to delegate:BNLoggingDelegate){
        self.loggingDelegate = delegate
    }

    public func setLogLevel(to loglevel:BNLogLevels) {
        self.logLevel = loglevel
    }
    
    public func send(message:Data, tag:Int=0) {
        self.socket?.write(message, withTimeout: self.timeoutInterval, tag: tag)
    }
    
    public func sendString(message: String, tag:Int = 0 ) {
        self.send(message: message.data(using: String.Encoding.utf8)!, tag: tag)
    }
    

    // MARK: Socket Functions
    // These functions are used by CocoaAsync to pass data along.
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        self.readData(data: data)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        // Starts listening for data.
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        self.debug("Data with tag \(tag) sent")
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        guard let error = err else {
            return
        }
        self.error(String(describing:error))
    }
    
    
    // MARK: Private Functions
    
    
    /// Internally handles incoming data
    /// - Parameter data: The incoming data
    fileprivate func readData(data:Data) {
        
        // Pass the data off the the handler
        self.incomingDataHandler?.receiveData(data: data, address: self.deviceIP, port: self.devicePort)
        
        // Starts listening for data again
        self.socket?.readData(withTimeout: -1, tag: 0)
        
        // Log it.
        self.debug(String(decoding: data, as: UTF8.self))
    }
    
    
    /// Internal logger for passing data to the logging handler
    /// - Parameters:
    ///   - logMessage: The message to log
    ///   - logLevel: The log level to send.
    private func _log(logMessage:String, logLevel:BNLogLevels = .INFO) {
        if logLevel.rawValue >= self.logLevel.rawValue {
            loggingDelegate?.log(logMessage: logMessage, logLevel: logLevel)
        }
    }
    
    private func debug(_ message:String) {
        self._log(logMessage: message, logLevel: .DEBUG)
    }
    
    private func info(_ message:String) {
        self._log(logMessage: message, logLevel: .INFO)
    }
    
    private func warn(_ message:String) {
        self._log(logMessage: message, logLevel: .WARN)
    }

    private func error(_ message:String) {
        self._log(logMessage: message, logLevel: .ERROR)
    }
    
    private func fail(_ message:String) {
        self._log(logMessage: message, logLevel: .FAIL)
    }

    
    
}


