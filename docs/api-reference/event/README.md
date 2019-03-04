# CENEvent

User's message event emitter.


## Subclass  

* [CENEventEmitter](../emitter)  


## Properties

<a id="channel"/>

[`@property NSString *channel`](#channel)  
See: [PubNub Channels](https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-)  
Channel name which is used by [chat](#chat) to deliver emitted event.

<a id="chat"/>

[`@property CENChat *chat`](#chat)  
[CENChat](../chat) from which user emitted [event](#event).

<br/><a id="event"/>

[`@property NSString *event`](#event)  
Emitted event name.
This name should be used as first parameter in [CENChat.on](../chat#on) method to handle it.


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

[Receiver](../event) which can be used to chain other methods call.  

### Example

Stop specific event handling.
```objc
self.emitCompletionHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle successful event emit.
};

self.event.off(@"$.emitted", self.emitCompletionHandlingBlock);
```

Stop multiple events handling.
```objc
self.emitCompletionHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any first emitted error.
};

self.event.off(@"$.error.*", self.emitCompletionHandlingBlock);
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

[Receiver](../event) which can be used to chain other methods call.  

### Example

```objc
self.anyHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any event emitted by object.
};

self.event.offAny(self.anyHandlingBlock);
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

[Receiver](../event) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" })
    .on(@"$.emitted", ^(CENEmittedEvent *event) {
        // Handle event emit completion.
    }).perform();
```

Handle one of multiple events once using wildcard.
```objc
self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" })
    .on(@"$.error.*", ^(CENEmittedEvent *event) {
        // Handle any emitted error.
    }).perform();
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

[Receiver](../event) which can be used to chain other methods call.  

### Example

```objc
self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" })
    .onAny(^(CENEmittedEvent *event) {
        // Handle any event emitted by object.
    }).perform();
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

[Receiver](../event) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" })
    .once(@"$.emitted", ^(CENEmittedEvent *event) {
        // Handle emitted event.
    }).perform();
```

Handle one of multiple events once using wildcard.
```objc
self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" })
    .once(@"$.error.*", ^(CENEmittedEvent *event) {
        // Handle any first emitted error.
    }).perform();
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

[Receiver](../event) which can be used to chain other methods call.  

### Example

Remove specific event handlers
```objc
self.event.removeAll(@"$.emitted");
```

Remove multiple event handlers
```objc
self.event.removeAll(@"$.error.*");
```


## Events

<a id="event-emitted"/>

[`$.emitted`](#event-emitted)  
Message successfully published.

### Properties:

| Name      | Type       |  Value                        | Description |
|:---------:|:----------:|:-----------------------------:| ----------- |
| `event`   | NSString * | `$.emitted`                   | Name of handled event. |
| `emitter` | id         | [CENEvent](../event) * | Object, which emitted local event. In this case it will be `self.event` since handler added to listen [event](#../event) emitted events. |
| `data`    | id         | `NSDictionary *`              | Payload [emitted](../../concepts/messages#receive-messages) by remote user. |

### Example

```objc
event.on(@"$.emitted", ^(CENEmittedEvent *event) {
    NSDictionary *payload = ((NSDictionary *)event.data)[CENEventData.data];
    
    NSLog(@"Event has been sent at: %@", payload[CENEventData.timetoken]);
});
```


<br/><br/><a id="event-error-emitter"/>

[`$.error.emitter`](#event-error-emitter)  
There was a problem fetching the state of this user.

### Properties:

| Name      | Type       |  Value                        | Description |
|:---------:|:----------:|:-----------------------------:| ----------- |
| `event`   | NSString * | `$.error.emitter`             | Name of handled event. |
| `emitter` | id         | [CENEvent](../event) * | Object, which emitted local event. In this case it will be `self.event` since handler added to listen [event](#../event) emitted events. |
| `data`    | id         | `NSError *`                   | Error instance with error information about what exactly went wrong during event publishing. |

### Example

```objc
chat.on(@"$.error.emitter", ^(CENEmittedEvent *event) {
    NSError *erro = event.data;
    
    NSLog(@"Event emit did fail: %@", error);
});
```