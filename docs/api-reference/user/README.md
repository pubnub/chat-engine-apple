# CENUser

Remote user representation model which allow to get information about user itself and interact with 
him using [direct](#direct) chat. 


## Subclass  

* [CENEventEmitter](../emitter)  
* [CENObject](../object)  


## Properties

<a id="direct"/>

[`@property CENChat *direct`](#direct)  
See: [CENChat](../chat)  
[Chat](../chat) which can be used to send direct (private) messages which right to this user.


<br/><br/><a id="feed"/>

[`@property CENChat *feed`](#feed)  
See: [CENChat](../chat)  
[Chat](../chat) which is used by [user](../user) to publish updates (public) which can
be observed by anyone.  


<br/><br/><a id="state"/>

[`@property NSDictionary *state`](#state)  
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

[Receiver](../user) which can be used to chain other methods call.  

### Example

Stop specific event handling.
```objc
self.errorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle state restore error.
};

self.user.off(@"$.error.state.param", self.errorHandlingBlock);
```

Stop multiple events handling.
```objc
self.errorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any emitted error.
};

self.user.off(@"$.error.*", self.errorHandlingBlock);
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

[Receiver](../user) which can be used to chain other methods call.  

### Example

```objc
self.anyErrorHandlingBlock = ^(CENEmittedEvent *event) {
    // Handle any event emitted by object.
};

self.user.offAny(self.anyErrorHandlingBlock);
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

[Receiver](../user) which can be used to chain other methods call.  

### Example

Handle specific event.
```objc
self.client.User(@"PubNub").create()
    .on(@"$.error.state.param", ^(CENEmittedEvent *event) {
        // Handler state restore error.
    });
```

Handle multiple events using wildcard.
```objc
self.client.User(@"PubNub").create()
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

[Receiver](../user) which can be used to chain other methods call.  

### Example

```objc
self.client.User(@"PubNub").create()
    .onAny(^(CENEmittedEvent *event) {
        // Handle any event emitted by object.
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

Handle specific event once.
```objc
self.client.User(@"PubNub").create()
    .once(@"$.error.state.param", ^(CENEmittedEvent *event) {
        // Handler state fetch error once.
    });
```

Handle one of multiple events once using wildcard.
```objc
self.client.User(@"PubNub").create()
    .once(@"$.error.*", ^(CENEmittedEvent *event) {
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

[Receiver](../chat) which can be used to chain other methods call.  

### Example

Remove specific event handlers
```objc
self.user.removeAll(@"$.error.state.param");
```

Remove multiple event handlers
```objc
self.user.removeAll(@"$.error.*");
```


## Events

<a id="event-created-user"/>

[`$.created.user`](#event-created-user)  
Fired when a [User](#../user) has been created within ChatEngine.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.created.user`            | Name of handled event. |
| `emitter` | id         | [CENUser](../user) * | Object, which emitted local event. In this case it will be `self.user` since handler added to listen [user](../user) emitted events. |
| `data`    | id         | `nil`                       | `$.created.user` doesn't have any data which can be passed to event handler. |

### Example

```objc
self.client.on(@"$.created.user", ^(CENEmittedEvent *event) {
    CENUser *user = event.emitter;
    
    NSLog(@"User was created: %@", user);
});
```


<br/><br/><a id="event-error-getstate"/>

[`$.error.getState`](#event-error-getstate)  
Notify locally what there was a problem during user state restore.

### Properties:

| Name      | Type       |  Value                      | Description |
|:---------:|:----------:|:---------------------------:| ----------- |
| `event`   | NSString * | `$.error.getState`          | Name of handled event. |
| `emitter` | id         | [CENUser](../user) * | Object, which emitted local event. In this case it will be `self.user` since handler added to listen [user](../user) emitted events. |
| `data`    | id         | `NSError *`                 | Error object which contain information about reason of state restore failure. |

### Example

```objc
self.user.on(@"$.error.getState", ^(CENEmittedEvent *event) {
    NSError *error = event.data;
    
    NSLog(@"User state restore did fail: %@", error);
});
```