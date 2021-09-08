//
//  File.swift
//  
//
//  Created by Eric Boxer on 8/4/21.
//

import Foundation
import CocoaAsyncSocket


public class UDPSender: NSObject, GCDAsyncUdpSocketDelegate {

    var socket:GCDAsyncUdpSocket?
    var deviceIP: String
    var networkInterface: String
    var bindPort: UInt16
    var devicePort:UInt16
    var socketQueue = DispatchQueue(label: BNDispatchQueues.UDP.rawValue)


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
            print(error)
        }

        do {
            if self.networkInterface != "" {
                try self.socket?.bind(toPort: self.bindPort, interface: self.networkInterface)
            } else {
                try self.socket?.bind(toPort: self.bindPort)
            }
        } catch let error {
            print(error)
        }
    }

    deinit {
        self.socket?.close()
    }

    
    /// Sends a UDP Data message
    /// - Parameters:
    ///   - message: Data to send
    ///   - toHost: The IP Address of the remote device or machine. If left blank it will use the IP Address from when the instance was created
    ///   - port: The Port of the remote device or machine. If left blank it will the Port from when the instace was created
    public func sendUDPData(message: Data, toHost:String = "", port:UInt16 = 0 ) {
        socket?.send(message, toHost: (toHost == "" ? self.deviceIP : toHost), port: (port == 0 ? self.devicePort : port), withTimeout: 4, tag: 0)
    }
    
    /// Sends a UDP String message
    /// - Parameters:
    ///   - message: String to send
    ///   - toHost: The IP Address of the remote device or machine. If left blank it will use the IP Address from when the instance was created
    ///   - port: The Port of the remote device or machine. If left blank it will the Port from when the instace was created
    public func sendUDPString(message: String, toHost:String = "", port:UInt16 = 0 ) {
        self.sendUDPData(message: message.data(using: String.Encoding.utf8)!, toHost: toHost, port: port)
    }
}
