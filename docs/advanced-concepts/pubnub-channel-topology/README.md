PubNub Channel's in ChatEngine  

### Global Chat / Channel  

By default the Global Channel is called `chat-engine`.  

Every [Chat](../../api-reference/chat) created within an instanced of 
[CENChatEngine](../../api-reference/chatengine) is prepended with the string `chat-engine#`.  

This allows you to create multi-tenant apps without overlap. For example, you may want to support 
multiple organizations with different top level ids. Every organization would have a unique global 
channel.  

Every channel created within ChatEngine thereafter is prepended with the global channel.  

### Channel Namespaces

Every Chats is created under a sub namespace dependent on the context and permissions.

<a id="globalchannel" />

[`globalChannel`](#globalchannel)

This is the channel for [ChatEngine.global](../../api-reference/chatengine#chat-global). All 
[User](../../api-reference/user)s have read and write access to this channel.  
```objc
NSLog(@"Global chat channel: '%@'", self.client.global.channel);
// Global chat channel: 'chat-engine'
```

<a id="globalchannel-and-chat-public" />

[`globalChannel + '#chat#public.*'`](#globalchannel-and-chat-public)

All public [chats](../../api-reference/chat) are created under this namespace. All 
[users](../../api-reference/user) have read and write access to this channel.  

```objc
CENChat *chat = self.client.Chat().name(@"custom-channel").create();

NSLog(@"Chat channel: '%@'", chat.channel);
// Chat channel: 'chat-engine#chat#public.#custom-channel'
```

<a id="globalchannel-and-chat-private" />

[`globalChannel + '#chat#private.*'`](#globalchannel-and-chat-private)

All private [chats](../../api-reference/chat) are created under this namespace. This namespace is 
locked down and no users have read or write access. They must be granted them.  
```objc
CENChat *privateChat = self.client.Chat().name(@"private-channel").private(YES).create();

NSLog(@"Chat channel: '%@'", privateChat.channel);
// Chat channel: 'chat-engine#chat#private.#private-channel'
```

<a id="globalchannel-user-uuid-read" />

[`globalChannel + '#user#' + myUUID + '#read.*'`](#globalchannel-user-uuid-read)

This is the namespace containing [user](../../api-reference/user) owned 
[chats](../../api-reference/chat). The user who's [CENUser.uuid](../../api-reference/user#uuid) 
matches `myUUID` has all permissions, while other [users](../../api-reference/user) only have read 
permissions. [CENUser.feed](../../api-reference/user#feed) belongs to this namespace.  
```objc
CENUser *user = self.client.User(@"joe").create();

NSLog(@"User feed chat channel: '%@'", user.feed.channel);
// User feed chat channel: 'chat-engine#user#joe#read#feed'
```

<a id="globalchannel-user-uuid-write" />

[`globalChannel + '#user#' + myUUID + '#write.*'`](#globalchannel-user-uuid-write)

This is the namespace containing [user](../../api-reference/user) owned 
[chats](../../api-reference/chat). The user who's [CENUser.uuid](../../api-reference/user#uuid) 
matches `myUUID` has all permissions, while other [users](../../api-reference/user) only have write 
permissions. [CENUser.direct](../../api-reference/user#direct) belongs to this namespace.  
```objc
CENUser *user = self.client.User(@"joe").create();

NSLog(@"User direct chat channel: '%@'", user.direct.channel);
// User direct chat channel: 'chat-engine#user#joe#write#direct'
```