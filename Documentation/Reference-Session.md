# CENSession

It is possible to synchronize all chats list change for local user represented by [Me](reference-me) using sessions. So, each time when one of devices where user authorized, join new chat or leave some - this events will be synchronized across all other online devices.  

Synchronization disabled by default and if required, can be enabled by setting [Configuration.synchronizeSession](reference-configuration#synchronizesession) to **YES**.  

### Properties

<a id="chats"/>

[`@property NSDictionary<NSString *, NSDictionary<NSString *, CENChat *> *> *chats`](#chats)  
Stores reference on dictionary which contain chats collection stored under [group](reference-chat-group)s name as keys. Each group chat collection represent dictionary where keys are name of [Chat](reference-chat)'s channel and value is chat instance.  

#### EXAMPLE

```objc
NSLog(@"User-defined chats: %@", self.client.me.session[CENChatGroups.custom]);
```

### Events

<a id="event-group-restored"/>

[`$.group.restored`](#event-group-restored)  
Fired when [session](reference-session) finished synchronization of chats for one of known chat [group](reference-chat-group)s has been completed.  

#### EXAMPLE

```objc
self.client.me.session.on(@"$.group.restored", ^(NSString *group) {
    NSLog(@"Completed synchronization of chats from '%@' group.", group);
});
```

<br/><a id="event-chat-join"/>

[`$.chat.join`](#event-chat-join)  
Fired when user join to new chat from another device using same account.  

#### EXAMPLE

```objc
self.client.me.session.on(@"$.chat.join", ^(CENChat *chat) {
    NSLog(@"I joined '%@' from another device.", chat.name);
});
```

<br/><a id="event-chat-leave"/>

[`$.chat.leave`](#event-chat-leave)  
Fired when user leave chat from another device using same account.  

#### EXAMPLE

```objc
self.client.me.session.on(@"$.chat.leave", ^(CENChat *chat) {
    NSLog(@"I leaved'%@' from another device.", chat.name);
});
```