Search is a way to retrieve old events that were fired before ChatEngine was loaded. This way, when someone reloads their page or closes the app, they'll see the old messages the next time they log in.

You can search for events by calling the [Chat.search](reference-chat#search) method:  
```objc
chat.search().event(@"message").create().search();
```

[Chat.search](reference-chat#search) returns an Event Emitter, so you subscribe to it's events just like other objects in ChatEngine.  
```objc
CENSearch *searchy = chat.search().event(@"message").limit(50).create();

searchy.on(@"ping", ^(NSDictionary *eventData) {
    NSLog(@"Message found: %@", eventData);
});

searchy.on(@"$.search.finish", ^{
    NSLog(@"End of search");
});

searchy.search();
```  

This will search through every event emitted in the chat until 50 `message` events are found or all events have been looked at. The `searchy.on` event emitter augments events just like [Chat.on](reference-chat#on).  

[Chat.search](reference-chat#search) is powered by [PubNub History](https://www.pubnub.com/docs/ios-objective-c/storage-and-history) and the same parameters can be input into the function call.  
```objc
CENSearch *searchy = chat.search()
    .event(@"message")
    .limit(50)
    .start(@123123123123)
    .end(@123123123133)
    .create()
    .search();

```  

Search will stop after looking through `1,0000` events and then emit the `$.search.pause` event. To search an additional 1,000 events, call [Search.next](reference-search#next).