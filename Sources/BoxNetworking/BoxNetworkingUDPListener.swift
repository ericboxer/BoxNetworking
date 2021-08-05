


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

public struct MulticastAddress {
    private var _address:String
    
    public init(address:String) {
        self._address = address
    }
    
    public var address:String {
        set(newVal) {
            self._address = newVal
        }
        
        get {
            return self._address
        }
    }
}

public class UDPListener: NSObject, GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate {
    
    var socket:GCDAsyncUdpSocket?
    var networkInterface:String
    var bindPort:UInt16
    var socketQueue = DispatchQueue(label: "UDP_Listener_Queue")
    var incomingDataHandler: NetworkingUDPDelegate?
    var multicastGroups: [MulticastAddress] = []


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
            print("Error binding: \(error)")
        }

        do {
            try  self.socket?.beginReceiving()
        } catch let error {
            print (error)
        }
    }
    

    public func setIncomingDataHandler(to handler:NetworkingUDPDelegate){
        self.incomingDataHandler = handler
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let hostAddress:String = GCDAsyncSocket.host(fromAddress: address)!
        let hostPort:UInt16 = GCDAsyncSocket.port(fromAddress: address)
        incomingDataHandler?.receiveData(data: data, address: hostAddress, port: hostPort)
    }
    
    
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
            print(error)
            throw(error)
        }
    }
    
    public func addMulticastGroup(_ multicastGroup:MulticastAddress) -> BoxNetowrkingReturn{
        
        do {
            if self.networkInterface != "" {
                try self.joinMulticastGroup(multicastGroupAddress: multicastGroup.address, interface: self.networkInterface)
            } else {
                try self.joinMulticastGroup(multicastGroupAddress: multicastGroup.address)
            }
            self.multicastGroups.append(multicastGroup)
            return .OK
            
        } catch {
            return .MULTICAST_JOIN_ERROR
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
    
    private func leaveAllMulticastGroups(){
        for mcast in self.multicastGroups {
            self.leaveMulticastGroup(multicastGroupAddress: mcast.address)
        }
    }

    public func close() {
        self.leaveAllMulticastGroups()
        self.socket?.close()
    }

}

