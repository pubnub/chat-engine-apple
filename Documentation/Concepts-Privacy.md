### Public Chat

This is an example of a public chat any [User](reference-user) can join.
```objc
CENChat *chat = self.client.Chat().name(@"channel").create();
```

### Private Chat

This is a private chat that a user must authenticated in. Usually this is done via [Chat.invite](reference-chat#invite). See [Private Chats](concepts-private-chats).  
```objc
CENChat *chat = self.client.Chat().name(@"channel").private(YES).create();
```  

## Direct Chat

[User.direct](reference-user#direct) is a [Chat](reference-chat) that any [User](reference-user) can [Chat.emit](reference-chat#emit) on, but only the user receives events on.  
This is helpful for sending messages directly to users, to ping them, or challenge them to a match. This channel is only readable by said user.  
```objc
// Me
me.direct.on(@"game-invite", ^(NSDictionary *payload) {
    CENUser *sender = payload[CENEventData.sender];
    NSString *map = payload[CENEventData.data][@"map"];

    NSLog(@"'%@' sent your a game invite on the map '%@'", sender.uuid, map);
});

// Another user.
them.direct.emit(@"game-invite").data(@{ @"map": @"de_dust" }).perform();
```  

### Feed Chat

[User.feed](reference-user#feed) is a [Chat](reference-chat) that only the User can [Chat.emit](reference-chat#emit) to but everyone can receive events on.  
[User](reference-user)s can use this to tell others of their status. This is useful for things like updating a temporary status ("user is typing...") or letting others know you've gone idle.  
For a more persistent status update, see the section in this tutorial on "state" and [User.state](reference-user#state).  
```objc
// Me
me.feed.emit(@"update.away").data(@{ 
    @"msg": @"I may be away from my computer right now" 
}).perform();

// Another user.
them.feed.connect()
them.feed.on(@"update.away", ^(NSDictionary *payload) {
    CENUser *sender = payload[CENEventData.sender];
    NSString *message = payload[CENEventData.data][@"msg"];

    NSLog(@"'%@' is aways: %@", sender.uuid, message);
});
```  

### PubNub Security

Security is controlled via [PubNub PAM](https://www.pubnub.com/docs/tutorials/pubnub-access-manager).  

### Encryption

It's possible to encrypt messages traveling over the network by supplying [Configuration.cipherKey](reference-configuration#cipherkey) property. See [Message Layer Encryption with AES256](https://www.pubnub.com/docs/ios-objective-c/pam-security#message_layer_encryption_with_aes256).