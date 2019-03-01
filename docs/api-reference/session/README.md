# CENSession

[Local user](../me) [chats](../chat) list synchronization session.

**Note:** Synchronization disabled by default and if required, can be enabled by setting 
[CENConfiguration.synchronizeSession](../configuration#synchronizesession) to **YES**.  


## Subclass  

* [CENEventEmitter](../emitter)  


## Properties

<a id="chats"/>

[`@property NSDictionary<NSString *, CENChat *> *chats`](#chats)  
Map of synchronized chat channel names to [chats](../chat) which they represent.


## Methods

<a id="off"/>

[`off(NSString *event, CENEventHandlerBlock handler)`](#off)  
Inherited From: [CENEventEmitter.off](../emitter#off)  
Unsubscribe from particular or multiple (wildcard) `events` by removing `handler` from listeners 
list.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event for which handler should be removed. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../session) which can be used to chain other methods call.  

### Example

Stop specific event handling.
```objc
self.restoreHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle user's chats group restore completion.
};

self.client.me.session.off(@"$.group.restored", self.restoreHandlingBlock);
```

Stop multiple events handling.
```objc
self.syncHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any chats synchronization event.
};

self.client.me.session.off(@"$.chat.*", self.syncHandlingBlock);
```


<br/><br/><a id="offany"/>

[`offAny(CENEventHandlerBlock handler)`](#offany)  
Inherited from: [CENEventEmitter.offAny](../emitter#offany)  
Unsubscribe from any events emitted by receiver by removing `handler` from listeners list.   

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which has been used during event handler registration. | 

### Returns:

[Receiver](../session) which can be used to chain other methods call.  

### Example

```objc
self.anyHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle event.
};
self.client.me.session.offAny(self.anyHandlingBlock);
```


<br/><br/><a id="on"/>

[`on(NSString *event, CENEventHandlerBlock handler)`](#on)  
Inherited From: [CENEventEmitter.on](../emitter#on)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and handle
it with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../session) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
self.client.me.session.on(@"$.group.restored", ^(CENEmittedEvent *event) {
    // Handle user's chats group restore completion.
});
```

Handle multiple events using wildcard.
```objc
self.client.me.session.on(@"$.chat.*", ^(CENEmittedEvent *event) {
    // Handle '$.chat.join' and / or '$.chat.leave' chats synchronization events.
});
```


<br/><br/><a id="onany"/>

[`onAny(CENEventHandlerBlock handler)`](#onany)  
Inherited From: [CENEventEmitter.onAny](../emitter#onany)  
Subscribe on any events which will be emitted by receiver and handle them with provided event 
handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle any events. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../session) which can be used to chain other methods call.  

### Example

```objc
self.client.me.session.onAny(^(CENEmittedEvent *event) {
    // Handle emitted event.
});
```


<br/><br/><a id="once"/>

[`once(NSString *event, CENEventHandlerBlock handler)`](#once)  
Inherited From: [CENEventEmitter.once](../emitter#once)  
Subscribe on particular or multiple (wildcard) `events` which will be emitted by receiver and 
handle it once with provided event handler.  

### Parameters:

| Name      | Type                 | Attributes | Description |
|:---------:|:--------------------:|:----------:| ----------- |
| `event`   | NSString *           |  Required  | Name of event which should be handled by `handler`. |
| `handler` | CENEventHandlerBlock |  Required  | Block / closure which will handle specified `event`. Block / closure pass only one argument - locally emitted event [representation object](../emitted-event). | 

### Returns:

[Receiver](../session) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
self.client.me.session.once(@"$.group.restored", ^(CENEmittedEvent *event) {
    // Handle user's chats group restore completion once.
});
```

Handle one of multiple events once using wildcard.
```objc
self.client.me.session.once(@"$.chat.*", ^(CENEmittedEvent *event) {
    // Handle any chats synchronization event.
});
```


<br/><br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)  
Inherited from: [CENEventEmitter.removeAll](../emitter#removeall)  
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  

### Parameters:

| Name    | Type       | Attributes | Description     |
|:-------:|:----------:|:----------:| --------------- |
| `event` | NSString * |  Required  | Name of event for which has been used to register handler blocks. | 

### Returns:

[Receiver](../session) which can be used to chain other methods call.  

### Example

Remove specific event handlers
```objc
self.client.me.session.removeAll(@"$.chat.join");
```

Remove multiple event handlers
```objc
self.client.me.session.removeAll(@"$.chat.*");
```



## Events

<a id="event-chat-join"/>

[`$.chat.join`](#event-chat-join)  
Notify locally when [local user](../me) join to new [chat](../chat) from another 
device using same account.  

### Properties:

| Name      | Type       |  Value                            | Description |
|:---------:|:----------:|:---------------------------------:| ----------- |
| `event`   | NSString * | `$.chat.join`                     | Name of handled event. |
| `emitter` | id         | [CENSession](../session) * | Object, which emitted local event. In this case it will be `self.client.me.session` since handler added to listen [session](../session) emitted events. |
| `data`    | id         | `CENChat *`                       | [Chats](../chat) to which [local user](../me) connected from another device. |

### Example

```objc
self.client.me.session.on(@"$.chat.join", ^(CENEmittedEvent *event) {
    CENChat *chat = event.data;
    
    NSLog(@"I joined '%@' from another device.", chat.name);
});
```

<br/><br/><a id="event-chat-leave"/>

[`$.chat.leave`](#event-chat-leave)  
Notify locally when [local user](../me) leave [chat](../chat) from another device 
using same account.  

### Properties:

| Name      | Type       |  Value                            | Description |
|:---------:|:----------:|:---------------------------------:| ----------- |
| `event`   | NSString * | `$.chat.leave`                    | Name of handled event. |
| `emitter` | id         | [CENSession](../session) * | Object, which emitted local event. In this case it will be `self.client.me.session` since handler added to listen [session](../session) emitted events. |
| `data`    | id         | [CENChat](../chat) *       | [Chats](../chat) which [local user](../me) leaved from another device. |

### Example

```objc
self.client.me.session.on(@"$.chat.leave", ^(CENEmittedEvent *event) {
    CENChat *chat = event.data;
    
    NSLog(@"I leaved '%@' from another device.", chat.name);
});
```


<br/><br/><a id="event-error-sync"/>

[`$.error.sync`](#event-error-sync)  
Notify locally when SDK was unable to complete local user session synchronization.

### Properties:

| Name      | Type       |  Value                            | Description |
|:---------:|:----------:|:---------------------------------:| ----------- |
| `event`   | NSString * | `$.error.sync`                    | Name of handled event. |
| `emitter` | id         | [CENSession](../session) * | Object, which emitted local event. In this case it will be `self.client.me.session` since handler added to listen [session](../session) emitted events. |
| `data`    | id         | `NSError *`                       | Error object which contain information about what exactly went wrong during last API usage. |

### Example

```objc
self.client.me.session.on(@"$.error.sync", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
});
```

<br/><br/><a id="event-group-restored"/>

[`$.group.restored`](#event-group-restored)  
Notify locally when [session](../session) did finish custom chats (created by 
[local user](../me)) group synchronization.  

### Properties:

| Name      | Type       |  Value                            | Description |
|:---------:|:----------:|:---------------------------------:| ----------- |
| `event`   | NSString * | `$.group.restored`                | Name of handled event. |
| `emitter` | id         | [CENSession](../session) * | Object, which emitted local event. In this case it will be `self.client.me.session` since handler added to listen [session](../session) emitted events. |
| `data`    | id         | `NSString *`                      | Custom [chats](../chat) group identifier. |

### Example

```objc
self.client.me.session.on(@"$.group.restored", ^(CENEmittedEvent *event) {
    NSString *group = event.data;
    
    NSLog(@"Completed synchronization of chats from '%@' group.", group);
});
```