## Create a chat room

The [CENChatEngine.Chat](../../api-reference/chatengine#chat) class allows you to create a new chat 
room. The user will automatically join the chat room when it is created if the `autoConnect` flag is
set to `YES`.

All chat rooms are created as public by default. A private chat room can be created by setting the 
`private` flag to `YES`.  

### Public chat

```objc
CENChat *chat = self.client.Chat().name(@"public-chat").create();
```  

### Private chat

```objc
CENChat *privateChat = self.client.Chat().name(@"private-chat").private(YES).create();
```

You can get a list of all chat rooms by using `ChatEngine.chats`.

```objc
NSLog(@"Chats: %@", self.client.chats);
CENChat *chat = self.client.Chat().name(@"public-chat").get();
```

### Chat metadata

The [CENChatEngine.Chat](../../api-reference/chatengine#chat) class can also define chat `metadata` 
for a chat room. Chat metadata persists on the server and can be accessed by calling 
[CENChat.meta](../../api-reference/chat#meta).

```objc
CENChat *chat = self.client.Chat().name(@"private-chat").meta(@{
    @"name": @"Soccer meetup",
    @"team": @"A"
}).create();
```

The [CENChat.update](../../api-reference/chat#update) method allows you to update chat `metadata`.

```objc
self.chat.update(@{
    @"name": @"Soccer meetup",
    @"team": @"B"
});
```


## Invite a user to a private chat room

The [CENChat.invite](../../api-reference/chat#invite) method allows you to invite other users to a 
private chat room.

```objc
CENUser *user = self.client.User(@"adam").get();
self.privateChat.invite(someoneElse);
```

### Listen to $.invite event

An [`$.invite`](../../api-reference/me#event-invite) event is emitted on the invited user's 
[direct](../../api-reference/user#direct) chat when they are invited to a private chat room. The 
user can listen to these events or retrieve them later by using 
[CENChat.search](../../api-reference/chat#search) on their direct chat channel.

```objc
self.client.me.direct.on(@"$.invite", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    CENChat *invitedChat = self.client.Chat(payload[CENEventData.data][@"channel"]).create();
});
```


## Show users in a chat room

You can get a list of online users connected to the chat room by calling 
[CENChat.users](../../api-reference/chat#users). The list is kept in sync as users join and leave 
the chats.

```objc
NSLog(@"Chat users: %@", self.chat.users);
```


## Leave a chat room

The [CENChat.leave](../../api-reference/chat#leave) method allows a user to leave a chat room and 
stop receiving events.

```objc
self.chat.leave();
```

### Listen to $.offline events

A [`$.offline.leave`](../../api-reference/chat#event-offline-leave) event is emitted when a 
[user](../../api-reference/user) intentionally leaves a chat room. Other users in the chat room can 
listen to `$.offline.*` to receive all $.leave events and mark the user as offline.

```objc
self.chat.on(@"$.offline.*", ^(CENEmittedEvent *event) {
    CENUser *user = event.data;
    NSLog(@"User left the room: %@", user.uuid);
});
```


### Listen to $.disconnected event

A [`$.disconnected`](../../api-reference/chat#event-disconnected) event is emitted towards the user 
when they are successfully disconnected from the chat room. The user can listen to the event to 
execute additional business logic upon leave.

```objc
self.chat.on(@"$.disconnected", ^(CENEmittedEvent *event) {
    // Disconnection completed.
});
```

