![BoxNetwrokingLogo]

Wrapper classes for the wonder [CocoaAsyncSocket Framework] to make life easier.

## Installation

### Swift Package Manager

### Manually

## Ussage

### General 

The communications classes are broken up by their function. By themselves they don't really do much except handle the netowrk traffic. It is up to you provided a delegate class for handling data.

```swift
import BoxNetworking

```

### UDP

UDP classes are broken up into **Senders** and **Listeners**. They do pretty much what it sounds like- the sender class sends messages and the listener class listens for messages.

``` swift
import BoxNetworking

// iSendMessages is a Sender class to a host at 10.0.1.100:6789. 
// Outgoing messages should be sent on port 6543
var iSendMessages = UPDSender(toIP "10.0.1.100", toPort: 6789, usingPort:6543)

// Send a String to the given host
iSendMessages.sendSgtring(message:"Hello World!")

// Send a string to a different host (because we can)
sendString(message: "Hello to you too!", toHost:String = "10.0.1.101", port:UInt16 = 54545)

```

### TCP

### Logging

Both types of socket wrappers allow for a delegate class that handles logging

```swift

// Create a class that conforls to the BNLoggingDelegate Protocol
class LogHandler:BNLoggingDelegate {
    func log(logMessage:String, logLevel:BNLogLevels) {
        print("\(logLevel):: \(logMessage)")
    }
}

// Assign LogHandler to iSendMessages class. Set its log level to DEBUG
iSendMessages.setLogDelegate(to:LogHandler)
iSendMessages.setLogLevel(to: BNLogLevels.DEBUG)

// Send a message with an optional tag for tracking
iSendMessages.sendString("Hello World", tag:1)

// Console: Data with tag 1 sent
```

## Dont Forget

### App Sandboxing

![appSandboxing]
This one gets me every. Single. Time. If you're having trouble with packets not sending ro being recevied be sure to double check your capabilities / entitlemnets (Sandboxing) for network data both incoming AND outgoing data.


## FAQs

- #### Does CocoaAsyncSockets really need a wrapper?
    Nope! But this makes it easer for me to use if without having the reconfigure everything every time I start a new project.
- #### Why use this if Apple has provided its own socket implimentation?
    I've had challanged with the framekworks selecting when they will and wont listen to incoming data. I at least know this works exactly as I expect it to.


[appSandboxing]: ./readmeAssets/appSandboxing.png
[BoxNetwrokingLogo]: ./readmeAssets/Blue_Background.png

[CocoaAsyncSocket Framework]:https://github.com/robbiehanson/CocoaAsyncSocket