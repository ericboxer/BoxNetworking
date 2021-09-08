import Foundation
import CocoaAsyncSocket



public class UDPListener: NSObject, GCDAsyncUdpSocketDelegate {
    
    var socket:GCDAsyncUdpSocket?
    var networkInterface:String
    var bindPort:UInt16
    var socketQueue = DispatchQueue(label: "UDP_Listener_Queue")
    var incomingDataHandler: BNReceiveDataDelegate?
    var multicastGroups: [MulticastAddress] = []
    
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
    
    
    deinit{
        self.close()
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
            return .OK
            
        } catch {
            return .MULTICAST_JOIN_ERROR
        }
    }
    
    /// Stops listening to a Multicast group.
    /// - Parameters:
    ///   - multicastGroupAddress: multicastGroupAddress description
    ///   - interface: <#interface description#>
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
    
    public func leaveAllMulticastGroups(){
        for multicastGroup in self.multicastGroups {
            self.leaveMulticastGroup(multicastGroupAddress: multicastGroup.address)
        }
    }

    public func close() {
        self.leaveAllMulticastGroups()
        self.socket?.close()
    }

}

