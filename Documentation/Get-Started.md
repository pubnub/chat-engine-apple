### Get Code

[ChatEngine](https://github.com/pubnub/chat-engine) can be integrated into your project using [CocoaPods](https://cocoapods.org). Next two steps will help prepare environment and project for [ChatEngine](https://github.com/pubnub/chat-engine) usage: 
1. Latest version of [CocoaPods](https://cocoapods.org) required. Following commands can be used to install and/or update [CocoaPods](https://cocoapods.org):  
    ```shell
    gem install cocoapods
    gem update cocoapods
    ```

2. Create or update existing [Podfile](https://guides.cocoapods.org/syntax/podfile.html) in your project root folder and add:
    ```ruby
    pod 'CENChatEngine'
    ```

### PubNub ChatEngine

PubNub ChatEngine is an object oriented event emitter based framework for building chat applications in Objective-C. It reduces the time to build chat applications drastically and provides essential components like typing indicators, online presence monitoring and message history out of the box.

The real time server component is provided by PubNub. ChatEngine is designed to be extensible and includes a plugin framework to make adding new features simple.

PubNub ChatEngine is an object oriented event emitter based framework for building chat applications in Objective-C. PubNub ChatEngine makes it easy to build Slack, Flowdock, Discord, Skype, Snapchat, or WhatsApp with ease.

The real time server component is provided by PubNub. PubNub ChatEngine is extensible and includes a plugin framework to make dropping in features simple.  

Include ChatEngine
```objc
#import <CENChatEngine/ChatEngine.h>
```

### Automagic PubNub Setup

[![automated-chatengine-setup](https://user-images.githubusercontent.com/794617/39043196-6a8f92a0-4495-11e8-957a-a3347878dc72.png)](https://chat-engine-setup.pubnub.com)

### Quick Setup

Follow the instructions below to create a simple chat lobby where you can see who's online and invite one another to private chats.

#### CONNECTION

First, we need to connect to [ChatEngine](reference-chatengine) via [ChatEngine.connect](reference-chatengine#connect). The values input into [ChatEngine.connect](reference-chatengine#connect) create a new [User](reference-user) called [Me](reference-me) that this client will act as.
```objc
self.client.connect(@"serhii").state(@{  "team": @"red" }).perform();
```

This will connect to [ChatEngine](reference-chatengine) with [Me.uuid](reference-me#uuid) equal to `serhii` a [Me.state](reference-me#state) of `@{ @"team": @"red" }`.

#### THE $.READY EVENT

Because [ChatEngine](reference-chatengine) must do some work to connect to the server, we must wait for it to respond before working with [Chats](reference-chat) and [Users](reference-user).

When [ChatEngine](reference-chatengine) is ready, it will emit [$.ready](reference-chatengine#event-ready). We can subscribe to this event with [ChatEngine.on](reference-chatengine#on).
```objc
self.client.on(@"$.ready", ^(CENMe *me) {
    NSLog(@"ChatEngine ready to go!");
});
```

The `$` represents a `system` event. You can read more about system events in the tutorial on [Namespaces](namespaces). You can subscribe to all system events via `self.client.on(@"$.*")`, read more in the tutorial on [Wildcards](wildcards).  

#### ME

When [ChatEngine.on](reference-chatengine#on) is fired, [Me](reference-me) is supplied.  
```objc
self.client.connect(@"serhii").state(@{  "team": @"red" }).perform();

self.client.on(@"$.ready", ^(CENMe *me) {
    self.me = me; // serhii
});
```

All calls made to [ChatEngine](reference-chatengine) are made on behalf of [Me](reference-me).

#### CHATS

Let's create [Chat](reference-chat) for us to join. We'll make a [Chat](reference-chat) through which our users can communicate.
```objc
CENChat *lobby = self.client.Chat().name(@"lobby").create();
```

This will create a new [Chat](reference-chat). We'll be connected to it automatically.  

#### USERS

So how do we see other other people online? Well [Me](reference-me) is automatically recorded as joining our [Chat](reference-chat), and any other person who runs this program will see `serhii` as a [user](reference-user) online on the [Chat](reference-chat).

You can get a list of online users via [Chat.users](reference-chat#users).   
```objc
NSLog(@"Users: %@", lobby.users);
```

Will output:
```objc
{
    "serhii": <CENUser::0x000000 uuid: 'serhii'; state set: NO>
}
```

If we were to open another window and connect as `stephen`, we would see `stephen` in `lobby.users`.
```objc
self.client.connect(@"stephen").state(@{  "team": @"blue" }).perform();
```

Let's chat with `stephen`.

#### SENDING MESSAGES

In order to chat, all we need to do is use the [Chat.emit](reference-chat#emit) method to send a message over the internet to all other clients who have the program running.
```objc
lobby.emit(@"message").data(@{ @"text": @"hey" }).perform();
```

`message` is an event name that is just a string identifier. It helps us tell the difference between different events. See [Events Namespaces](namespaces) and [Wildcards](wildcards) for more.

`data` accept `NSDictionary` which represent the `message` payload. This data is sent over the internet to all subscribing parties.

#### LISTENING FOR MESSAGES

We can get notified a new message by using [Chat.on](reference-chat#on). The `text` value is available as `payload[CENEventData.data][@"text"]`.   
```objc
lobby.on(@"message", ^(NSDictionary *payload) {
    NSLog(@"Greetings: %@", payload[CENEventData.data][@"text"]);
});
```

We can also get the [User](reference-user) that sent the `message` and the [Chat](reference-chat) the message was sent to. For more on this, see [Event Payload](event-payload). 
```objc
lobby.on(@"message", ^(NSDictionary *payload) {
    CENChat *chat = payload[CENEventData.chat];
    CENUser *sender = payload[CENEventData.sender];

    NSLog(@"%@ sent a message to %@ with value: %@", sender.uuid, chat.name, payload[CENEventData.data]);
});
```

#### STATE

But hey, what if we want more information about the user that sent the `message`. Remember how we supplied `@{ @"team": @"red" }` during [ChatEngine.connect](reference-chatengine#connect)?  
```objc
self.client.connect(@"serhii").state(@{  "team": @"red" }).perform();
```

We can get that value with [User.state](reference-user#state). This value will be the same on every machine because state is synced between everybody.  
```objc
lobby.on(@"message", ^(NSDictionary *payload) {
    CENUser *sender = payload[CENEventData.sender];

    NSLog(@"%@ sent a message: %@", sender.uuid, payload[CENEventData.data][@"text"]);
    NSLog(@"the are on '%@' team", sender.state[@"team"]);
});
```

#### PRIVATE CHAT
What if we want to invite `stephen` into a private chat? We can find `stephen` from our list of users in the lobby. See [Chat.users](reference-chat#users).

We can use `stephen`'s uuid to get his [User](reference-user).
```objc
CENUser *stephen = lobby.users[@"stephen"];
```

Ok, let's make a new chat and invite him to it. We'll create a new [Chat](reference-chat) and then fire the [Chat.invite](reference-chat#invite) which invites a [User](reference-user) to a [Chat](reference-chat).
```objc
CENChat *privateChat = self.client.Chat().name(@"private").private(YES).create();
privateChat.invite(stephen);
```

So how does `stephen` know that he got invited? [Chat.invite](reference-chat#invite) sends `stephen` a direct message that nobody else can see over a special [Chat](reference-chat) called [User.direct](reference-user#direct).

`stephen` can find out when someone invites him by subscribing to the `$.invite` event via [Me.direct](reference-me#direct). The key for the new chat that we created is available as `payload[CENEventData.data][@"channel"]`.
```objc
me.direct.on(@"$.invite", ^(NSDictionary *payload) {
    CENChat *invitedChat = self.client.Chat().name(payload[CENEventData.data][@"channel"]).create();

    invitedChat.emit(@"message").data(@{ @"text": @"hello everybody!" }).perform();
});
```

#### USING PLUGINS
What if we want to support [Markdown](https://en.wikipedia.org/wiki/Markdown) in our messages? We can use a ChatEngine plugin. Plugins are loaded via the [Chat.plugin](reference-chat#plugin), [User.plugin](reference-user#plugin), [Me.plugin](reference-me#plugin), or [ChatEngine.proto](reference-chatengine#proto).  
First, we need to add corresponding plugin to `Podfile`:  
```ruby
pod 'CENChatEngine/Plugin/Markdown'
```  

Import plugin into file, where [Chat](reference-chat) will be created and plugin registered:  
```objc
#import <CENChatEngine/CENMarkdownPlugin.h>
```
  
Then we create a new [Chat](reference-chat) and attach the plugin to it via [Chat.plugin](reference-chat#plugin).
```objc
CENChat *pluginChat = self.client.Chat().name(@"markdown-chat").create();
pluginChat.plugin([CENMarkdownPlugin class]).store();
```  

And now, when someone sends a message via [Chat.emit](reference-chat#emit)...
```objc
pluginChat.emit(@"This is some *markdown* **for sure**.").perform();
```

The markdown plugin will parse markdown and replace it as **NSAttributedString**.  
  
Check out the tutorials on [Plugins](concepts-plugins) and how [Build a Plugin](concepts-build-a-plugin).