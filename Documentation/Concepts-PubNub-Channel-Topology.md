PubNub Channel's in ChatEngine  

### Global Chat / Channel  

By default the Global Channel is called `chat-engine`.  

Every [Chat](reference-chat) created within an instanced of [ChatEngine](reference-chatengine) is perpended with the string `chat-engine#`.  

This allows you to create multi-tenant apps without overlap. For example, you may want to support multiple organizations with different top level ids. Every organization would have a unique global channel.  

Every channel created within ChatEngine thereafter is prepended with the global channel.  

### Channel Namespaces

Every Chats is created under a sub namespace dependent on the context and permissions.

<a id="globalchannel" />

[`globalChannel`](#globalchannel)

This is the channel for [ChatEngine.global](reference-chatengine#global). All [User](reference-user)s have read and write access to this channel.  
```objc
NSLog(@"Global chat channel: '%@'", self.client.global.channel);
// Global chat channel: 'chat-engine'
```

<a id="globalchannel-and-chat-public" />

[`globalChannel + '#chat#public.*'`](#globalchannel-and-chat-public)

All public [Chat](reference-chat)s are created under this namespace. All [User](reference-user)s have read and write access to this channel.  
```objc
CENChat *chat = self.client.Chat().name(@"custom-channel").create();

NSLog(@"Chat channel: '%@'", chat.channel);
// Chat channel: 'chat-engine#chat#public.#custom-channel'
```

<a id="globalchannel-and-chat-private" />

[`globalChannel + '#chat#private.*'`](#globalchannel-and-chat-private)

All private [Chat](reference-chat)s are created under this namespace. This namespace is locked down and no users have read or write access. They must be granted them.  
```objc
CENChat *privateChat = self.client.Chat().name(@"private-channel").private(YES).create();

NSLog(@"Chat channel: '%@'", privateChat.channel);
// Chat channel: 'chat-engine#chat#private.#private-channel'
```

<a id="globalchannel-user-uuid-read" />

[`globalChannel + '#user#' + myUUID + '#read.*'`](#globalchannel-user-uuid-read)

This is the namespace containing [User](reference-user) owned [Chat](reference-chat)s. The user who's [User.uuid](reference-user#uuid) matches `myUUID` has all permissions, while other [User](reference-user)s only have read permissions. [User.feed](reference-user#feed) belongs to this namespace.  
```objc
CENUser *user = self.client.User(@"joe").create();

NSLog(@"User feed chat channel: '%@'", user.feed.channel);
// User feed chat channel: 'chat-engine#user#joe#read#feed'
```

<a id="globalchannel-user-uuid-write" />

[`globalChannel + '#user#' + myUUID + '#write.*'`](#globalchannel-user-uuid-write)

This is the namespace containing [User](reference-user) owned [Chat](reference-chat)s. The user who's [User.uuid](reference-user#uuid) matches `myUUID` has all permissions, while other [User](reference-user)s only have write permissions. [User.direct](reference-user#direct) belongs to this namespace.  
```objc
CENUser *user = self.client.User(@"joe").create();

NSLog(@"User direct chat channel: '%@'", user.direct.channel);
// User direct chat channel: 'chat-engine#user#joe#write#direct'
```