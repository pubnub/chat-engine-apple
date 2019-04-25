[ChatEngine.global](reference-chatengine#chat-global) is a global [Chat](reference-chat) room that all instances of [ChatEngine](reference-chatengine) connect to by default. It is a convenience property that provides some handy utility.  

It makes it easy to send/emit a message to all connected clients:  
```objc
self.client.global.emit(@"message").data(@{ @"text": @"Sale going on now!" }).perform();
```  

We also get a list of all online users connected to this instance of ChatEngine.
```objc
NSLog(@"Online users: %@", self.client.global.users.allKeys);
```  

So how does it work?  

* All [Users](reference-user) connect to [ChatEngine.global](reference-chatengine#chat-global) by default (during [ChatEngine.connect](reference-chatengine#connect))
* [Me.update](reference-me#update) and [User.state](reference-user#state) operates using [ChatEngine.global](reference-chatengine#chat-global). See: [Users and State](concepts-users-and-state)