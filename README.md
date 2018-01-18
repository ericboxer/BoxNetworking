# BoxNetworking
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 

### The Challange
[CococaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) is a fantastic framework, but I found myself writing the same code over and over again.
I made it a bit easier for myself by creating a helper framework with a few added features.

### Usage
#### Simple initialization
```swift
let socket = BoxNetworkingUDP(destinationIPAddress: "10.0.1.100", listenPort: 5005, sourcePort: 5006)
```

#### Simple sending of Data and String types
```swift
socket.sendUDP(message: "Hello World")
```

#### Simple receive handling through delegation
```swift
func receiveData( data:Data, address: Data) {
  // handle the data here
}
```

#### Theres even a built in method to conver Data to String
```swift
BoxNetworkingHelper.dataToString(data: data)
```

### Instalation
#### [Carthage.](https://github.com/Carthage/Carthage)
```
github "ericboxer/BoxNetworking" "master"
```

