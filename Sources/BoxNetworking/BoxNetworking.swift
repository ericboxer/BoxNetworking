


import Foundation
import CocoaAsyncSocket






/**
 A delegate protocol for handling incoming data from a socket
 - Parameters:
    - data: That incoming data in raw Data format
    - address: The source IP address
    - port: The source Port
 - Returns: Void
 
 
 */

public protocol NetworkingUDPDelegate {
    func receiveData(data:Data, address:String, port:UInt16)
}



public class UDPListener: NSObject, GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate {
    
    var socket:GCDAsyncUdpSocket?
    var networkInterface:String
    var bindPort:UInt16
    var socketQueue = DispatchQueue(label: "UDP_Listener_Queue")
    public var incomingDataProcessor: NetworkingUDPDelegate?


    
    public init(onAddress networkInterface:String="", onPort bindPort:UInt16) {
        self.networkInterface = networkInterface
        self.bindPort = bindPort

        super.init()

        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.socketQueue)

        do {
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

        do {
            try  self.socket?.beginReceiving()
        } catch let error {
            print (error)
        }
    }
    
    

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let hostAddress:String = GCDAsyncSocket.host(fromAddress: address)!
        let hostPort:UInt16 = GCDAsyncSocket.port(fromAddress: address)
        incomingDataProcessor?.receiveData(data: data, address: hostAddress, port: hostPort)
    }
    
    public func joinMulticastGroup(multicastGroupAddress:String, interface:String = "") {
        do {
            if interface != "" {
                try self.socket?.joinMulticastGroup(multicastGroupAddress, onInterface: interface)
            } else {
                try self.socket?.joinMulticastGroup(multicastGroupAddress)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    public func leaveMulticastGroup(multicastGroupAddress:String, interface:String=""){
        do {
            if interface != "" {
                try self.socket?.leaveMulticastGroup(multicastGroupAddress, onInterface: interface)
            } else {
                try self.socket?.leaveMulticastGroup(multicastGroupAddress)
            }
            
        } catch let error {
            print(error)
        }
    }


}


public class UDPSender: NSObject, GCDAsyncUdpSocketDelegate {

    var socket:GCDAsyncUdpSocket?
    var deviceIP: String
    var networkInterface: String
    var bindPort: UInt16
    var devicePort:UInt16
    var socketQueue = DispatchQueue(label: "UDPNetworking")



    var networkingUDPDelegate: NetworkingUDPDelegate?

    init(toIP ipAddress:String, toPort devicePort:UInt16, usingIP networkInterface: String = "", usingPort bindPort:UInt16) {
        self.deviceIP = ipAddress
        self.networkInterface = networkInterface
        self.devicePort = devicePort
        self.bindPort = bindPort


        super.init()


        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: self.socketQueue)


        do {
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



    func sendUDPData(message: Data) {
        socket?.send(message, toHost: self.deviceIP, port: self.devicePort, withTimeout: 4, tag: 0)
    }

    func sendUDP(message: String) {
        self.sendUDPData(message: message.data(using: String.Encoding.utf8)!)
    }
    
    

}
