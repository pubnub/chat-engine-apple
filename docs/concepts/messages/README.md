## Send messages

The [CENChat.emit](../../api-reference/chat#emit) method allows you to send messages once a user is 
connected to a chat room. In the code below, `@"message"` is the event name and the 
`@{ @"text": @"hey" }` object is the event payload.

```objc
self.chat.emit(@"message").data(@{ @"text":  @"hey" }).perform();
```

## Receive messages

The [CENChat.on](../../api-reference/chat#on) listener allows you to receive messages in a chat 
room.

```objc
self.chat.on(@"message", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    NSDictionary *data = payload[CENEventData.data];
    CENUser *user = payload[CENEventData.sender];
    CENChat *chat = payload[CENEventData.chat];
    
    NSLog(@"'%@' sent: %@", user.uuid, data[@"text"]);
});
```

Although you may send any valid object using [CENChat.emit](../../api-reference/-chat#emit), when 
the same `payload` is received by other users, it is augmented with additional data. The original 
message stored in received `payload` under `CENEventData.data` key. You can also access chat room 
and sender details by accessing data stored in `payload` under `CENEventData.sender` and 
`CENEventData.chat` keys.

## Send a direct message to a user

While users can send messages to other users by creating private chat rooms, they can also send 
private messages to other users through users' [direct](../../api-reference/user#direct) chat rooms.

For instance, in the example below, the user can send a private message to Adam's direct chat.

```objc
CENUser *user = self.client.User(@"adam").get();
adam.direct.emit(@"message").data(@{ @"text":  @"hello buddy!" }).perform();
```

Adam can call [CENChat.on](../../api-reference/chat#on) on his own direct chat to receive incoming 
messages.

```objc
self.client.me.direct.on(@"message", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    NSDictionary *data = payload[CENEventData.data];
    CENUser *user = payload[CENEventData.sender];
    
    NSLog(@"'%@' sent you a direct message: %@", user.uuid, data[@"text"]);
});
```

Users only have write permissions to other users' direct chat and cannot add a listener to receive 
messages on the chat.

## Retrieve past messages

The [CENChat.search](../../api-reference/chat#search) method can be used to retrieve old events that
were fired before ChatEngine was loaded or when users were 
[disconnected](../../api-reference/chat#event-offline-disconnect) from chat.

```objc
CENSearch *search = self.chat.search().event(@"message").limit(50);
search.on(@"message", ^(CENEmittedEvent *event) {
    NSLog(@"This is an old event!\n%@", event.data);
}).on(@"$.search.finish", ^(CENEmittedEvent *event) {
    NSLog(@"We have all our results!");
});

search.search();
```

If no `limit` and `count` is set, search will stop after looking through the `1,000` most recent 
messages and then emit the `$.search.pause` event. The `search.next()` method can be used to search 
an additional `1,000` events. The code sample below shows how to implement `$.search.pause` and get 
the next set of messages if [CENSearch.hasMore](../../api-reference/search#hasmore) is true.

```objc
CENSearch *search = self.chat.search().event(@"message").pages(2);

search.on(@"message", ^(CENEmittedEvent *event) {
    NSDictionary *payload = event.data;
    NSDictionary *data = payload[CENEventData.data];
    
    NSLog(@"Got an old message: %@", data[@"text"]);
}).on(@"$.search.pause", ^(CENEmittedEvent *event) {
      NSLog(@"Searched 2 pages for messages.");
      
      if (search.hasMore) {
          // Call 'next' to try another 2 pages.
          search.next();
      }
});
```