[Chats](reference-chat) are the core object in ChatEngine. Chats are rooms of connected ChatEngine [Users](reference-user).  
A new chat can be made by calling:
```objc
CENChat *chat = self.client.Chat().name(@"tutorial-chat").create();
```  

The chat will automatically connect when created. Them, the client will be in [Chat](reference-chat) with every other client that has a copy if that on their device.  

You can get notified of where a chat is connected by subscribing on the [$.connected](reference-chat#event-connected) event.  
```objc
chat.on(@"$.connected", ^{
    NSLog(@"The chat is connected!");
});
```  

### Chat events

When two clients both join a [Chat](reference-chat) with the same channel name (`tutorial-chat` in this case), they can communicate with one another.  

This communication happens through [Events](concepts-events). To send an event to everyone in a [Chat](reference-chat), call the [Chat.emit](reference-chat#emit) method.  
```objc
chat.emit(@"message").data(@{ @"text": @"Hello world!" }).perform();
```  

This will send the `message` event to every other client in the [Chat](reference-chat).  
To get notified when a `message` is sent to the [Chat](reference-chat), a client can call the [Chat.on](reference-chat#on) method.  
```objc
chat.on(@"message", ^(NSDictionary *payload){
    NSLog(@"Received payload: %@", payload);
});
```  

See [Events](concepts-events) for more information about events.  

### What else can Chats do?
[Chats](reference-chats) have plenty of cool features. Check out other tutorials:  
* [Events](concepts-events)  
* [Online List](concepts-online-list)  
* [Search](concepts-search)  
* [Privacy](concepts-privacy)  
* [Plugins](concepts-plugins)  

For example, [Chat.users](reference-chat#users) contain a list of all the other [Users](reference-user) online in the chat. That list of users will update automatically.