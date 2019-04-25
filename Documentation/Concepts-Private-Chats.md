### Private Chats  

A user may want to make a private chat no other users can access. To do this, create a new chat with the syntax:  
```objc
CENChat *privChat = self.client.Chat().name(@"channel").private(YES).create();
```  

`private` parameter tells ChatEngine to lock down the chat and only make it accessible to those who are invited.  


### Inviting to Private Chats

In order to securely invite other users to the chat, the client can call the [Chat.invite](reference-chat#invite) method.  
```objc
CENUser *otherUser = self.client.global.users[@"ian"];
privChat.invite(otherUser);
```  

This will send `otherUser` a secure invite to the [Chat](reference-chat) via [User.direct](reference-user#direct).

### Receiving invites to Private Chats

You can get notified of invites by subscribing to the [$.invite](reference-me#event-invite) event.  
```objc
me.direct.on(@"$.invite", ^(NSDictionary *payload) {
    CENChat *privateChat = self.client.Chat().name(payload[CENEventData.data][@"channel"]).create();
});
```