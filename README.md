![BoxNetwrokingLogo]

Wrapper classes for the wonder [CocoaAsyncSocket Framework] to make life easier.

## Installation

### Swift Package Manager

### Manually

## Ussage

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