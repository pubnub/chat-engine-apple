Events are the life-blood of ChatEngine. Events let us know when other [Users](reference-user) do thing in our [Chat](reference-chat).  
ChatEngine emit's some events automatically. All ChatEngine events start with `$.`, see [Namespaces](concepts-namespaces) for more on that.  
Our custom events can be any string, like `message` or `like`. Let's define a custom event so we can send and receive text messages between applications.  

### Emitting Events to Users in Chat

First, let's `emit()` a simple text string as `message` event over the [Chat](reference-chat). See [Chat.emit](reference-chat#emit) for more.  
```objc
lobby.emit(@"message").data(@{ @"msg": @"Hey, this is Serhii!" }).perform();
```  

This will broadcast the `message` event over the Internet to all other clients. Subscribe ti the event using [Chat.on](reference-chat#on) to get notified of the event.  

### Subscribe to Events

You can subscribe to custom events by supplying any string as first parameter in `on()`. The second parameter is handler block that will be run whenever the event is emitted by ANY other user in the same [Chat](reference-chat).  
```objc
chat.on(@"message", ^(NSDictionary *payload) {
    CENUser *sender = payload[CENEventData.sender];

    NSLog(@"'%@' emitted the value: %@", sender.uuid, payload[CENEventData.data]);
});
```  

Anytime you or any other client uses the `emit()` method with the same event name, it will fire the handler block defined in `on()` on every client subscribed to it.  
Curious about `payload[CENEventData.sender]` and `payload[CENEventData.data]`? See [Event Payload](concepts-event-payload).