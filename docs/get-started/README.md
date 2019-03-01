### Get Code

PubNub ChatEngine is a client-side framework for building chat applications. It reduces the time to 
build chat and provides essential components like typing indicators, online presence monitoring and 
event history. It also includes a hosted PubNub Function for access control and security.

ChatEngine is designed to be extensible and includes a plugin library to make adding new features 
simple.

## Install with CocoaPods

1. Create or update existing [Podfile](https://guides.cocoapods.org/syntax/podfile.html) in your 
project root folder and add:
   ```ruby
   pod 'CENChatEngine'
   ```
2. Install required dependencies:
   ```text
   pod install
   ```

## Source Files:

```text
https://github.com/pubnub/chat-engine-apple
```

## License:

```text
https://github.com/pubnub/chat-engine-apple/blob/master/LICENSE
```

## Account Setup

Start by creating a PubNub account. Your account must be configured specifically for ChatEngine 
using the tool below.

<iframe src="https://chatengine-quickstart-app.pubnub.com/signup" title="ChatEngine Automagic Setup" class="chatengine-auto-setup"></iframe>

Your account should now be configured. You can log into your 
[PubNub Admin Portal](https://admin.pubnub.com) to view your ChatEngine settings and continue with 
development.

In the portal, you will see that a ChatEngine application has been created with publish and 
subscribe keys. The application has the Presence, Storage & Playback, Functions and Access Manager 
features enabled, which are required for ChatEngine.

A PubNub Function has also been created which assists with securely accessing PubNub from a browser
environment.