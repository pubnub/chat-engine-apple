[Users](../../api-reference/user) are other applications connected to the 
[chat](../../api-reference/chat) via [CENChatEngine](../../api-reference/chatengine). A 
[user](../../api-reference/user) represents a connected client.


## Find a user

The [CENChatEngine.User](../../api-reference/chatengine#user) class allows you to create or find a 
user by providing a `uuid`.

```objc
// Will create new user or return existing.
CENUser *user = self.client.User(@"joe").create();
```


## Get state for online users

You can also get state for online users by calling [CENUser.state](../../api-reference/user#state).

```objc
CENUser *user = self.client.User(@"joe").get();

NSLog(@"Joe's state: %@", user.state);
```


## Online and offline status

ChatEngine generates [$.online.*](../../api-reference/chat#event-online-here) and 
[$.offline.*](../../api-reference/chat#event-offline-disconnect) events for each user when they 
[join](../../api-reference/chat#event-online-join) or 
[leave](../../api-reference/chat#event-offline-leave) chat rooms. 
These events can be consumed by other users in the chat room to show `online`/`offline` status.

* When a new user joins a chat room, a [$.online.join](../../api-reference/chat#event-online-join) 
  event is emitted.
* When an existing user joins a chat room, a [$.online.here](../../api-reference/chat#event-online-here)
  event is emitted.
* When a user intentionally leaves a chat room, a [$.offline.leave](../../api-reference/chat#event-offline-leave) 
  event is emitted.
* When a user loses network connectivity, a [$.offline.disconnect](../../api-reference/chat#event-offline-disconnect)
  event is generated.
  
### Listen to $.online events

```objc
self.client.on(@"$.online.*", ^(CENEmittedEvent *event) {
    CENChat *chat = event.emitter;
    CENUser *user = event.data;
    
    NSLog(@"'%@' is in %@", user.uuid, chat.name);
});
```

### Listen to $.offline events

```objc
self.client.on(@"$.offline.*", ^(CENEmittedEvent *event) {
    CENChat *chat = event.emitter;
    CENUser *user = event.data;
    
    NSLog(@"'%@' left %@", user.uuid, chat.name);
});
```