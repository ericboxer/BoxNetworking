


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



public enum BoxNetowrkingReturn:String {
    case OK = "OK"
    case FAIL = "Failed"
    case ERROR = "Error"
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

    public func addMulticastGroup(_ multicastGroup:MulticastAddress) -> BoxNetowrkingReturn{
        
        do {
            if self.networkInterface != "" {
                try self.joinMulticastGroup(multicastGroupAddress: multicastGroup.address, interface: self.networkInterface)
            } else {
                try self.joinMulticastGroup(multicastGroupAddress: multicastGroup.address)
            }
            self.multicastGroups.append(multicastGroup)
            return BoxNetowrkingReturn.OK
            
        } catch {
            return BoxNetowrkingReturn.ERROR
        }
    }
    
    
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let hostAddress:String = GCDAsyncSocket.host(fromAddress: address)!
        let hostPort:UInt16 = GCDAsyncSocket.port(fromAddress: address)
        incomingDataHandler?.receiveData(data: data, address: hostAddress, port: hostPort)
    }
    
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

