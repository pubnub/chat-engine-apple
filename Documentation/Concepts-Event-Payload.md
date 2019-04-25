### Event Payload

Although you mat emit any valid JSON using [Chat.emit](reference-chat#emit), when the same event is received by other [Users](reference-user), it will be augmented with additional data.  
```objc
@{
    CENEventData.sender: ChatEngine.User(),  // the User responsible for emitting the message.
    CENEventData.chat: ChatEngine.Chat(),    // the Chat the event was broadcasted over.
    CENEventData.data: @{ ... },             // Anything sent to Chat.emit() shows up here.
    CENEventData.event: NSString,            // Name of event for which payload has been created.
    CENEventData.timetoken: NSNumber,        // Event publish unixtimestamp.
    CENEventData.eventID: NSString           // Unique event identifier.
}
```  

You can find the actual message content supplied to [Chat.emit](reference-chat#emit) in payload under `CENEventData.data` key.  
ChatEngine event payloads are augmented with additional information supplied by the framework. Most of the time these are `CENEventData.sender` and `CENEventData.chat`.  
The property `CENEventData.chat` is the [Chat](reference-chat) that event was broadcast on, and the `CENEventData.sender` is the [User](reference-user) that broadcast the message via [Chat.emit](reference-chat#emit).  
The [User](reference-user) and [Chat](reference-chat) fields are both fully interactive instances. Therefor, you can do things like `payload[CENEventData.chat].emit(@"message).perform()"` to automatically reply to a message.  

### Simple Example

In this demo we'll mock up a user named 'Serhii' emitting the 'like' event on a user named 'Alex'.  
In application used by Serhii:  
```objc
// Connect with UUID 'Serhii' and add a user state.
self.client.connect(@"Serhii").state(@{  @"fullName": @"Serhii Mamontov" }).perform();

// Emit a 'like' event over global chat.
self.client.global.emit(@"like").data(@{ @"who": @"alex" }).perform();
```  

In application used by Alex:  
```objc
// Connect with UUID 'Alex'.
self.client.connect(@"Alex").perform();

// When we received a 'like' event on global chat.
self.client.global.on(@"like", ^(NSDictionary *state) {
    // If jay exempt matches 'alex'.
    if ([payload[CENEventData.data][@"who"] isEqualToString:@"alex"]) {
        CENUser *sender = payload[CENEventData.sender];
        CENChat *chat = payload[CENEventData.chat];
        
        // Log 'Serhii Mamontov' from Serhii's state.
        NSLog(@"His full name is: %@", sender.state[@"fullName"]);
        
        // Get all the other users in the chat that emitted this event.
        NSLog(@"Other users who saw this are: %@", chat.users);
    }
});
```