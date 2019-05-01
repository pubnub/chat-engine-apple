# CENMe

Special type of [user](../user) which represent currently connected client with write 
permissions and ability to update it's state.


## Subclass  

* [CENUser](../user)  
* [CENObject](../object)  
* [CENEventEmitter](../emitter)  


## Properties

<a id="direct"/>

[`@property CENChat *direct`](#direct)  
Inherited From: [CENUser.direct](../user#direct)  
[Chat](../chat) which can be used to send direct (private) messages which right to this user.   


<br/><br/><a id="feed"/>

[`@property CENChat *feed`](#feed)  
Inherited From: [CENUser.feed](../user#feed)  
[Chat](../chat) which is used by [user](../user) to publish updates (public) which can
be observed by anyone.

<br/><br/><a id="session"/>

[`@property CENSession *session`](#session)  
[Object](../session) which allow to synchronize chats list change between 
[local user](../me) devices.  

<br/><br/><a id="state"/>

[`@property NSDictionary *state`](#state)  
Inherited From: [CENUser.state](../user#state)  
`NSDictionary` which represent user's state bound to 
[CENChatEngine.global](../chatengine#chat-global) chat.  
See [CENMe.update](../me#update) for how to assign state values.


## Methods

<a id="extension"/>

[`extension(id plugin)`](#extension)  
Inherited from: [CENObject.extension](../object#extension)  
Access receiver's interface extensions.

<br/><br/><a id="off"/>

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

[Receiver](../me) which can be used to chain other methods call.  

### Example

Stop specific event handling.
```objc
self.errorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle state update error.
};

self.client.me.off(@"$.error.getState", self.errorHandlingBlock);
```

Stop multiple events handling.
```objc
self.errorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any first emitted error.
};

self.client.me.off(@"$.error.*", self.errorHandlingBlock);
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

[Receiver](../me) which can be used to chain other methods call.  

### Example

```objc
self.anyErrorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any emitted events.
};
self.client.me.offAny(self.anyErrorHandlingBlock);
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

[Receiver](../me) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
self.client.me.on(@"$.error.getState", ^(CENEmittedEvent *event) {
    // Handler state update error.
});
```

Handle multiple events using wildcard.
```objc
CENChat *chat = self.client.Chat().name(@"test-chat").create()
    .on(@"$.error.*", ^(CENEmittedEvent *event) {
        // Handle any emitted error.
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

[Receiver](../me) which can be used to chain other methods call.  

### Example

```objc
self.client.me.onAny(^(CENEmittedEvent *event) {
    // Handle any emitted events.
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

[Receiver](../me) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
self.client.me.once(@"$.error.getState", ^(CENEmittedEvent *event) {
    // Handler state update error once.
});
```

Handle one of multiple events once using wildcard.
```objc
self.client.me.once(@"$.error.*", ^(CENEmittedEvent *event) {
    // Handle any first emitted error.
});
```


<br/><br/><a id="plugin-exists"/>

[`plugin(id).exists()`](#plugin-exists)  
Inherited From: [CENObject.plugin](../object#plugin-exists)  
Check whether plugin exists using specified parameters.  
 

<br/><br/><a id="plugin-remove"/>

[`plugin(id).remove()`](#plugin-remove)  
Inherited From: [CENObject.plugin](../object#plugin-remove)  
Remove plugin using specified parameters.  
 

<br/><br/><a id="plugin-store"/>

[`plugin(id).identifier(NSString *).configuration(NSDictionary *).store()`](#plugin-store)  
Inherited From: [CENObject.plugin](../object#plugin-store)  
Create plugin using specified parameters.  

<br/><br/><a id="removeall"/>

[`removeAll(NSString *event)`](#removeall)  
Inherited from: [CENEventEmitter.removeAll](../emitter#removeall)  
Unsubscribe all `event` or multiple (wildcard) `events` handlers.  

### Parameters:

| Name    | Type       | Attributes | Description     |
|:-------:|:----------:|:----------:| --------------- |
| `event` | NSString * |  Required  | Name of event for which has been used to register handler blocks. | 

### Returns:

[Receiver](../me) which can be used to chain other methods call.

### Example

Remove specific event handlers
```objc
self.client.me.removeAll(@"$.error.getState");
```

Remove multiple event handlers
```objc
self.client.me.removeAll(@"$.error.*");
```


<br/><br/><a id="update"/>

[`update(NSDictionary *state)`](#update)  
Update [local user](../me) state in a [CENChatEngine.global](../chatengine#chat-global) chat.  
All other [users](../user) will be notified of this change via 
[$.state](../chat#event-state). 
Retrieve state at any time with [CENUser.state](../user#state).

### Parameters

| Name      | Type           | Description |
|:---------:|:--------------:| ----------- |
| `state`   | NSDictionary * | `NSDictionary` which contain updated state for [local user](../me). |  

### Returns:

[Receiver](../me) which can be used to chain other methods call.  

### Fires:

* [`$.error.auth`](../chat#event-error-auth)   

### Example

```objc
self.client.me.update(@{ @"state": @"working" });
```

## Events

<a id="event-created-me"/>

[`$.created.me`](#event-created-me)  
Notify locally when [local user](#../me) has been created within 
[CENChatEngine](../chatengine).

### Properties:

| Name      | Type       |  Value                  | Description |
|:---------:|:----------:|:-----------------------:| ----------- |
| `event`   | NSString * | `$.created.me`          | Name of handled event. |
| `emitter` | id         | [CENMe](../me) * | Object, which emitted local event. |
| `data`    | id         | `nil`                   | `$.created.me` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.client.on(@"$.created.me", ^(CENEmittedEvent *event) {
    CENMe *me = event.emitter;
    
    NSLog(@"Me was created: %@", me);
});
```


<br/><br/><a id="event-error-getstate"/>

[`$.error.getState`](#event-error-getstate)  
Notify locally what there was a problem during user state restore.

### Properties:

| Name      | Type       |  Value                  | Description |
|:---------:|:----------:|:-----------------------:| ----------- |
| `event`   | NSString * | `$.error.getState`      | Name of handled event. |
| `emitter` | id         | [CENMe](../me) * | Object, which emitted local event. |
| `data`    | id         | `NSError *`             | Error object which contain information about reason of state restore failure. |

### Example

```objc
self.client.on(@"$.error.getState", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
    
    NSLog(@"User state restore did fail: %@", error);
});
```

<br/><br/><a id="event-invite"/>

[`$.invite`](#event-invite)  
Tutorial: [Chat Rooms](../../concepts/chat-rooms)  
Notify locally when [local user](../me) has been invited to a new [chat](../chat). 
Fired by the [CENChat.invite](../chat#invite) method.

### Properties:

| Name      | Type       |  Value                  | Description |
|:---------:|:----------:|:-----------------------:| ----------- |
| `event`   | NSString * | `$.invite`              | Name of handled event. |
| `emitter` | id         | [CENMe](../me) * | Object, which emitted local event. In this case it will be `self.client.me` since handler added to listen [me](../me) emitted events. |
| `data`    | id         | `NSDictionary *`        | Payload with channel information, which has been [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
self.client.me.direct.on(@"$.invite", ^(CENEmittedEvent *event) {
    NSDictionary *payload = ((NSDictionary *)event.data)[CENEventData.data];
    
    CENChat *secretChat = self.client.Chat().name(payload[@"channel"]).create();
});
```