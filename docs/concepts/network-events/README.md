## Disconnect from ChatEngine

The [CENChatEngine.disconnect](../../api-reference/chatengine#disconnect) method allows you to 
disconnect a user from ChatEngine. You should call the method before exiting the application so 
connections with PubNub are closed gracefully.

```objc
self.client.disconnect();
```

## Reconnect to ChatEngine

ChatEngine configured to restore connection after network errors. ChatEngine will receive 
`$.network.down.*` and `$.network.up.*` events when the OS detects network changes.

## Reconnect to Existing Chats

ChatEngine automatically reconnects the user to existing chats if the `synchronizeSession` flag is 
set to `YES` when ChatEngine is initialized. You can use local user 
[session](../../api-reference/me#session) to retrieve a list of chats that the user has connected to
before. The list is kept in sync as users join and leave chat rooms.  

```objc
self.client.on(@"$.group.restored", ^(CENEmittedEvent *event) {
    NSString *group = event.data;
    
    NSLog(@"Chats: %@", self.client.me.session.chats);
});
```