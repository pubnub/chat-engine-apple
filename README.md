![](https://raw.githubusercontent.com/pubnub/chat-engine/master/images/logo.png)

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

## [Markdown Support](https://github.com/pubnub/chat-engine-apple/wiki/plugins-markdown)

## [Online User Search](https://github.com/pubnub/chat-engine-apple/wiki/plugins-online-user-search)

## [Typing Indicator](https://github.com/pubnub/chat-engine-apple/wiki/plugins-typing-indicator)

## [Unread Messages](https://github.com/pubnub/chat-engine-apple/wiki/plugins-unread-messages)

## [Push Notifications](https://github.com/pubnub/chat-engine-apple/wiki/plugins-push-notifications)

## [Gravatar Support](https://github.com/pubnub/chat-engine-apple/wiki/plugins-gravatar)

Uses Gravatar service to create an avatar based on user state information.

## [Random Usernames](https://github.com/pubnub/chat-engine-apple/wiki/plugins-random-username)

A plugin that gives every use a random username combining a color and an animal.

# Tests

To run tests, follow next steps:  
* Ensure what [latest](https://itunes.apple.com/ua/app/xcode/id497799835?mt=12) Xcode version installed.  
* Ensure what latest CocoaPods installed by calling from Terminal:  
  ```sudo gem install cocoapods```  
* Clone repository and navigate to it's root  
* Pull out dependencies by calling from Terminal:  
  ```pod install```  
* Navigate to `Tests/Tests/Resources` subdirectory and rename `demo-test-keysset.plist` to `test-keysset.plist`. This file values (publish / subscribe keys) used only in case of new Fixtures generation.  
* Navigate to `Tests` subdirectory and open `ChatEngine Tests.xcworkspace`  
* At top left of Xcode find drop down menu which contain following useful tests:  
  * `Code Coverage (Unit)` - performs **unit** tests and generate code coverage report  
  * `Code Coverage (Integration)` - performs **integration** tests and generate code coverage report  
  * `Code Coverage (Full)` - runs both **unit** and **integration** tests with code coverage report. **Note:** this case sometimes behave not as expected because **unit** uses OCMock library to patch code and sometime it doesn't get released in time to remove altered behavior.  
