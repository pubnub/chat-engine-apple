This repository is a part of the [ChatEngine Framework](https://github.com/pubnub/chat-engine).
For more information on building chat applications with PubNub, see our
[Chat Resource Center](http://www.pubnub.com/developers/chat-resource-center/).

![](https://raw.githubusercontent.com/pubnub/chat-engine/master/images/logo.png)

[![Build Status](https://travis-ci.org/pubnub/chat-engine-apple.svg?branch=master)](https://travis-ci.com/pubnub/chat-engine-apple)

[Documentation](https://www.pubnub.com/docs/chat-engine)

# Deprecation Notice

ChatEngine has been deprecated with no plans for additional releases. Support for the ChatEngine SDK will end on July 16, 2021. If you have questions about ChatEngine, please contact us at support@pubnub.com.
Please visit our newer chat product, [PubNub Chat](https://www.pubnub.com/products/pubnub-chat/). 

PubNub ChatEngine is an object oriented event emitter based framework for building chat applications in Objective-C. It reduces the time to build chat applications drastically and provides essential components like typing indicators, online presence monitoring and message history out of the box.

The real time server component is provided by PubNub. ChatEngine is designed to be extensible and includes a plugin framework to make adding new features simple.

# Docs

You can find the full docs on [the full documentation website](https://github.com/pubnub/chat-engine-apple/wiki/get-started). Concepts are linked below for convenience.

# Concepts

* [Me](https://github.com/pubnub/chat-engine-apple/wiki/concepts-me) - It's you dummy. The user that represents the current application.
* [Users and State](https://github.com/pubnub/chat-engine-apple/wiki/concepts-users-and-state) - Explains how to interact with other users using ChatEngine and get additional information about them.
* [Chats](https://github.com/pubnub/chat-engine-apple/wiki/concepts-chats) - ChatEngine's bread and butter. These are isolated rooms that users can talk to each other in.
* [Events](https://github.com/pubnub/chat-engine-apple/wiki/concepts-events) - Events are things that happen in a chat. Like ```message``` or ```image_upload``` for example.
* [Event Payload](https://github.com/pubnub/chat-engine-apple/wiki/concepts-event-payload) - The data that comes with an event. Includes things like who sent the event and what chat it was sent to.
* [Namespaces](https://github.com/pubnub/chat-engine-apple/wiki/concepts-namespaces) - ChatEngine has a lot of events, so we use name spacing to isolate them.
* [Wildcards](https://github.com/pubnub/chat-engine-apple/wiki/concepts-wildcards) - Get all the events of a single namespace, like $.online.* to get all types of online events.
* [Search](https://github.com/pubnub/chat-engine-apple/wiki/concepts-search) - Retrieve old events that happened in the past. Usually done when your application boots up to show what happened before.
* [Global Chat](https://github.com/pubnub/chat-engine-apple/wiki/concepts-global-chat) - The chat that all users connect to. It's used for state management and application wide events.
* [Online List](https://github.com/pubnub/chat-engine-apple/wiki/concepts-online-list) - Get all the users online in the chat room.
* [Authentication](https://github.com/pubnub/chat-engine-apple/wiki/concepts-authentication) - How to use auth keys to identify your users and protect access to channels.
* [Privacy](https://github.com/pubnub/chat-engine-apple/wiki/concepts-privacy) - Every user has a special feed chat that only they can publish to, and a direct chat that nobody else can read from. Outlines other ways of handling permissions as well.
* [Private Chats](https://github.com/pubnub/chat-engine-apple/wiki/concepts-private-chats) - Create private chats that nobody else can join.
* [Errors](https://github.com/pubnub/chat-engine-apple/wiki/concepts-errors) - Sometimes things don't go as planned, here's how you can catch errors gracefully.
* [Plugins](https://github.com/pubnub/chat-engine-apple/wiki/concepts-plugins) - Drop in extra functionality, like emojii or typing indicators with plugins.
* [Building a Plugin](https://github.com/pubnub/chat-engine-apple/wiki/concepts-build-a-plugin) - If what you need doesn't exist, it's easy to build yourself. Share it with us!
* [PubNub Functions](https://github.com/pubnub/chat-engine-apple/wiki/concepts-pubnub-functions) - ChatEngine uses PubNub functions as a server component and details about that can be found here.
* [PubNub Channel Topology](https://github.com/pubnub/chat-engine-apple/wiki/concepts-pubnub-channel-topology) - Describes what PubNub channels ChatEngine is using under the hood.


# Plugins

## [Image Uploads](https://github.com/pubnub/chat-engine-apple/wiki/plugins-uploadcare)

Uses [UploadCare](https://uploadcare.com) service to upload images and render them in chats.

## [Markdown Support](https://github.com/pubnub/chat-engine-apple/wiki/plugins-markdown)

Render Markdown in [NSAttributedString](https://developer.apple.com/documentation/foundation/nsattributedstring?language=objc) when receiving messages.

## [Mute Users](https://github.com/pubnub/chat-engine-apple/wiki/plugins-muter)

Allows the current user to stop receiving events from other users.

## [Online User Search](https://github.com/pubnub/chat-engine-apple/wiki/plugins-online-user-search)

A simple way to search through the list of users online in the chat.

## [Typing Indicator](https://github.com/pubnub/chat-engine-apple/wiki/plugins-typing-indicator)

Provides convenience methods that fire when a user starts or stops typing.

## [Unread Messages](https://github.com/pubnub/chat-engine-apple/wiki/plugins-unread-messages)

Allows you to mark a chat as being in the background and increments a counter as events are sent to it.

## [Emoji Support](https://github.com/pubnub/chat-engine-apple/wiki/plugins-emoji)

Uses images as fallback for devices that might not yet support 💩.

## [Event Status and Read Receipts](https://github.com/pubnub/chat-engine-apple/wiki/plugins-event-status)

Emits additional events when someone reads a receives and/or reads a message.

## [Push Notifications](https://github.com/pubnub/chat-engine-apple/wiki/plugins-push-notifications)

## [Gravatar Support](https://github.com/pubnub/chat-engine-apple/wiki/plugins-gravatar)

Uses Gravatar service to create an avatar based on user state information.

## [Random Usernames](https://github.com/pubnub/chat-engine-apple/wiki/plugins-random-username)

A plugin that gives every use a random username combining a color and an animal.


# Development

## Setting up environment

It is required to install Xcode and CocoaPods on machine which will be used for application development. 
Perform following steps to complete environment preparation:  
1. Install Xcode from [AppStore](https://itunes.apple.com/ua/app/xcode/id497799835?mt=12),
2. After installation will be completed, launch Xcode and follow instruction to install command-line utilities,
3. Install [CocoaPods](https://cocoapods.org) by running following command from _Terminal_:  
   ```text
   sudo gem install cocoapods
   ```

After completion of these steps you can start building your application.

## Running Tests

You should complete [environment setup](#setting-up-environment) before trying to build and run tests.
At this moment there is **1198** tests in total (**80** integration and **1118** unit tests). To run whole
tests suite it will require **~11 minutes**.  

Xcode project for tests contains various build configurations, where particular type of tests can be chosen:
_unit_, _integration_, _unit with code coverage_, _integration with code coverage_ and all tests with code coverage.

To be able to run tests, follow next instruction:  
1. Clone repository:
   ```text
   git clone git@github.com:pubnub/chat-engine-apple.git
   ```
2. Navigate to _Tests_ project directory:
   ```text
   cd <path to clone location>/chat-engine-apple/Tests
   ```
3. Install required dependencies (list of dependencies can be seen in [Podfile](https://github.com/pubnub/chat-engine-apple/blob/develop/Tests/Podfile)):
   ```text
   pod install
   ```
4. After dependencies will be installed you should open project using `ChatEngine Tests.xcworkspace` file.
5. At top left of opened window you should be able to find drop down list with following targets:  
   * `[Test] Code Coverage (Full)`
   * `[Test] Code Coverage (Integration)`
   * `[Test] Code Coverage (Unit)`
   * `[Test] iOS Integration`
   * `[Test] iOS Unit`
6. After desired target has been chosen, ensure what iPhone simulator (with blue background) is chosen for 
   tests deployment.
7. Hit shortcut `Cmd+U` to launch test suite.


# Migration from 0.9.2 to 0.9.3

Events handler signature has been changed for better Swift support. From now on all events handler will 
receive only instance of [CENEmittedEvent](https://github.com/pubnub/chat-engine-apple/wiki/reference-emitted-event) type. 

Here is how handler looks like now:  
```objc
self.client.me.direct.on(@"$.invite", ^(CENEmittedEvent *event) {
    NSDictionary *payload = ((NSDictionary *)event.data)[CENEventData.data];
    CENUser *sender = payload[CENEventData.sender];
    
    CENChat *secretChat = self.client.Chat().name(payload[@"channel"]).create();
});
```

## Support

- If you **need help**, have a **general question**, have a **feature request** or to file a **bug**, contact <support@pubnub.com>.
