//
//  File.swift
//  
//
//  Created by Eric Boxer on 8/4/21.
//

import Foundation
import CocoaAsyncSocket

// MARK: UDP Sender Class

public class UDPSender: NSObject, GCDAsyncUdpSocketDelegate {
    var socket:GCDAsyncUdpSocket?
    
    var deviceIP: String
    var networkInterface: String
    var bindPort: UInt16
    var devicePort:UInt16
    var socketQueue = DispatchQueue(label: BNDispatchQueues.UDP.rawValue)
    var logLevel:BNLogLevels = .INFO
    
    // Delegate Assignments
    var loggingDelegate: BNLoggingDelegate?


    public override var description: String{
        return "\(type(of: self)) - Sending on \(self.networkInterface):\(self.bindPort)"
    }

    var networkingUDPDelegate: BNReceiveDataDelegate?
    

    
    /// A UDP Sender Class
    /// - Parameters:
    ///   - ipAddress: The IP Address (IPv4) of the location or device you are communicating with.
    ///   - devicePort: The Port of the location or device you are communicating with.
    ///   - networkInterface: The local interface (IPv4) you want to communicate on. Leave blank to auto select.
    ///   - bindPort: The local port you want to send from.
    public init(toIP ipAddress:String, toPort devicePort:UInt16, usingIP networkInterface: String = "", usingPort bindPort:UInt16) {
        self.deviceIP = ipAddress
        self.networkInterface = networkInterface
        self.devicePort = devicePort
        self.bindPort = bindPort

        super.init()

        // Set up the CocoaAsyncSocket Socket
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.socketQueue)

        do {
            // Attempt to reuse the socket address. This is important if you use the same port as a listener.
            try self.socket?.enableReusePort(true)
        } catch let error {
            self.error(String(describing: error))
        }

        do {
            
            var conncetionLogMessage:String = ""
            if self.networkInterface != "" {
                try self.socket?.bind(toPort: self.bindPort, interface: self.networkInterface)
                conncetionLogMessage = "UDP Sender Created at \(self.networkInterface):\(self.bindPort)"
            } else {
                try self.socket?.bind(toPort: self.bindPort)
                conncetionLogMessage = "UDP Sender Created on port \(self.bindPort)"
            }
            self.info(conncetionLogMessage)
        } catch let error {
            self.error(String(describing: error))
        }
    }

    deinit {
        self.close()
    }

    
    // MARK: Public User Functions
    
    public func close() {
        self.socket?.close()
    }
    
    // These are functions exposed to the user

    /// Sends a UDP Data message
    /// - Parameters:
    ///   - message: Data to send
    ///   - toHost: The IP Address of the remote device or machine. If left blank it will use the IP Address from when the instance was created
    ///   - port: The Port of the remote device or machine. If left blank it will the Port from when the instace was created
    public func send(message: Data, toHost:String = "", port:UInt16 = 0, tag:Int = 0 ) {
        self.socket?.send(message, toHost: (toHost == "" ? self.deviceIP : toHost), port: (port == 0 ? self.devicePort : port), withTimeout: 4, tag: tag)
    }
    
    /// Sends a UDP String message
    /// - Parameters:
    ///   - message: String to send
    ///   - toHost: The IP Address of the remote device or machine. If left blank it will use the IP Address from when the instance was created
    ///   - port: The Port of the remote device or machine. If left blank it will the Port from when the instace was created
    public func sendString(message: String, toHost:String = "", port:UInt16 = 0, tag:Int = 0 ) {
        self.send(message: message.data(using: String.Encoding.utf8)!, toHost: toHost, port: port, tag: tag)
    }
    
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        self.debug("Data with tag \(tag) sent")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        self.error("Data with tag \(tag) not sent: \(error!)")
    }
    
    
    // MARK: Private Functions
    
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



// MARK: UDP Listener Class
public class UDPListener: NSObject, GCDAsyncUdpSocketDelegate {
    
    var socket:GCDAsyncUdpSocket?
    var networkInterface:String
    var bindPort:UInt16
    var socketQueue = DispatchQueue(label: "UDP_Listener_Queue")
    var multicastGroups: [MulticastAddress] = []
    var logLevel:BNLogLevels = .INFO
    
    // Delegate Assignments
    var incomingDataHandler: BNReceiveDataDelegate?
    var loggingDelegate: BNLoggingDelegate?
    
    public override var description: String {
        return "\(type(of: self)) - Listening on \(self.networkInterface):\(self.bindPort)"
    }

    
    /// A UDP Listener or a specific port and optional interface. Do not specify the interface if using Multicast.
    /// - Parameters:
    ///   - networkInterface: The local interface to listen for Data on.
    ///   - bindPort: The port to listen for Data on.
    public init(onAddress networkInterface:String="", onPort bindPort:UInt16) {
        self.networkInterface = networkInterface
        self.bindPort = bindPort

        super.init()

        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.socketQueue)

        do {
            try self.socket?.enableReusePort(true)
        } catch let error {
            self.error(String(describing:error))
        }


        do {
            if self.networkInterface != "" {
                try self.socket?.bind(toPort: self.bindPort, interface: self.networkInterface)
            } else {
                try self.socket?.bind(toPort: self.bindPort)
            }
        } catch let error {
            self.error(String(describing:error))
        }

        do {
            try  self.socket?.beginReceiving()
        } catch let error {
            self.error(String(describing:error))
        }
    }
    
    
    deinit{
        self.close()
    }
    
    
    // MARK: Public Functions
    
    public func close() {
        self.leaveAllMulticastGroups()
        self.socket?.close()
    }
    
    /// Assign a class as to Handle and Process the incoming Data.
    /// - Parameter handler: The name of the Class that handles the incoming Data.
    public func setIncomingDataHandler(to handler:BNReceiveDataDelegate){
        self.incomingDataHandler = handler
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let hostAddress:String = GCDAsyncSocket.host(fromAddress: address)!
        let hostPort:UInt16 = GCDAsyncSocket.port(fromAddress: address)
        incomingDataHandler?.receiveData(data: data, address: hostAddress, port: hostPort)
    }
    
    
    // MARK: Multicast
    
    /// Joins a multicast group
    /// - Parameters:
    ///   - multicastGroupAddress: A string representing a multicast group
    ///   - interface: A binding interface to listen to the multicast group on
    /// - Throws: Multicast join error
    private func joinMulticastGroup(multicastGroupAddress:String, interface:String = "") throws {
        do {
            if interface != "" {
                try self.socket?.joinMulticastGroup(multicastGroupAddress, onInterface: interface)
            } else {
                try self.socket?.joinMulticastGroup(multicastGroupAddress)
            }
            
        } catch let error {
            self.error(String(describing:error))
            throw(error)
        }
    }
    
    /// Add a Multicast group to listen to.
    /// - Parameter multicastGroup: The Multicast Address to listen on
    /// - Returns: Join status
    public func addMulticastGroup(_ multicastGroup:MulticastAddress) -> BNReturnStatus{
        
        do {
            if self.networkInterface != "" {
                try self.joinMulticastGroup(multicastGroupAddress: multicastGroup.address, interface: self.networkInterface)
            } else {
                try self.joinMulticastGroup(multicastGroupAddress: multicastGroup.address)
            }
            self.multicastGroups.append(multicastGroup)
            
            self.info("Joined multicast group \(multicastGroup.address)")
            
            return .OK

            
        } catch {
            return .MULTICAST_JOIN_ERROR
        }
    }
    
    /// Stops listening to a Multicast group.
    /// - Parameters:
    ///   - multicastGroupAddress: The multicast group you want to leave
    ///   - interface: The network interface to communicate over
    public func leaveMulticastGroup(multicastGroupAddress:String, interface:String=""){
        do {
            if interface != "" {
                try self.socket?.leaveMulticastGroup(multicastGroupAddress, onInterface: interface)
            } else {
                try self.socket?.leaveMulticastGroup(multicastGroupAddress)
            }
            self.info("Left multicast group: \(multicastGroupAddress)")
        } catch let error {
            self.error(String(describing: error))
        }
    }
    
    public func leaveAllMulticastGroups(){
        for multicastGroup in self.multicastGroups {
            self.leaveMulticastGroup(multicastGroupAddress: multicastGroup.address)
        }
    }
    
    // MARK: Private Functions
    
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
